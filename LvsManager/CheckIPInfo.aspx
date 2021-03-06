﻿<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<script language="C#" runat="server">
    /************************************************************************************/
    // 使用步骤：
    // 1、修改第29行代码 GlobalClassName 变量的值，为你的Global.asax.cs的完整命名空间+类名
    // 2、在你的项目 Global.asax.cs 里增加如下代码：
    /*
        public static DateTime LAST_ACCESS_TIME_KEY = DateTime.Now;                 // 最近一次用户访问的时间
        public static int AccessCount = 0;                                          // 站点启动以来，正常用户访问次数
        void Application_EndRequest(object sender, EventArgs e)
        {
            string url = Request.Url.ToString().ToLower();
            // 记录活动时间，用于判断站点是否被用户使用中（这些判断代码注意要屏蔽测试页面）
            if (url.IndexOf("iswebmon=", StringComparison.Ordinal) < 0 &&           // 站点监控程序访问，不作为用户
                url.IndexOf("/checkipinfo.aspx", StringComparison.Ordinal) < 0 &&   // 前端轮询时，不作为用户
                url.IndexOf("/z.aspx", StringComparison.Ordinal) < 0)               // 这里修改为你自己站点的测试页面
            {
                LAST_ACCESS_TIME_KEY = DateTime.Now;
                Interlocked.Increment(ref AccessCount);
            }
     */
    /************************************************************************************/

    // Global.asax.cs里的完整类名，带命名空间，用于后面反射获取最近访问时间
    private static string GlobalClassName = "MyWeb.WebApiApplication";
    // 上下线开关状态保存到的文件名
    private static string StatusSavePath  = Path.Combine(@"e:\data", ReplaceNonValidChars(HttpContext.Current.Server.MapPath("."), "_") + ".onoffconfig");
    private static List<string> _whiteIpList;
    /// <summary>
    /// 允许设置上下线状态的ip列表,请根据实际项目修改ip
    /// </summary>
    private static List<string> WhiteIpList
    {
        get
        {
            if(_whiteIpList == null)
            {
                lock(lockobj)
                {
                    if (_whiteIpList == null)
                    {
                        _whiteIpList = new List<string>();
                        _whiteIpList.Add("127.");          // localhost本地地址
                        _whiteIpList.Add("218.85.23.101"); // VPN出口IP
                        _whiteIpList.Add("110.80.152.72"); // 办公出口IP
                    }
                }
            }
            return _whiteIpList;
        }
    }



    private const int ONLINE_CODE = 200;
    private const string ONLINE = "ONLINE";
    private const int OFFLINE_CODE = 503;
    private const string OFFLINE = "OFFLINE";
    static readonly object lockobj = new object();
    static Assembly nowAssembly;
    const string ymd = "yyyy-MM-dd HH:mm:ss";

    /// <summary>
    /// 所有接口都写在这里了
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        //获取当前服务器的上下线状态，如果获取不到，则默认为在线状态
        string currentState = GetCurrentStatus() ? ONLINE : OFFLINE;
        DateTime now = DateTime.Now;
        Response.ContentEncoding = Encoding.UTF8;

        //==============================================================================================================
        // 工具接口：进行状态查询：根据当前服务器最后一次请求时间判断服务器是否已经下线
        //==============================================================================================================
        if (Request.QueryString["getrealstate"] != null)
        {
            DateTime lastRequestTime = DateTime.MinValue;
            object accessCount = "";
            Type globalType = GetType(GlobalClassName);

            if (globalType != null)
            {
                object obj = GetStaticField(globalType, "LAST_ACCESS_TIME_KEY");
                if (obj != null)
                {
                    lastRequestTime = (DateTime) obj;
                }
                accessCount = GetStaticField(globalType, "AccessCount");
            }

            if (Request.QueryString["format"] != null && Request.QueryString["format"].Equals("robot"))
            {
                //服务器上次请求时间|当前时间|当前服务器的上下线设置状态
                Response.Write(string.Format("{0}|{1}|{2}|{3}", lastRequestTime.ToString(ymd), now.ToString(ymd), currentState, accessCount));
            }
            else
            {
                Response.Write(string.Format("当前状态：{5}，站点目录：{6}<br />服务器最近用户请求时间：{0}，当前时间：{1}，" +
                                             "间隔了：<span style=\"font-weight:bold; color:red;\">{2}</span> 秒<br />{3}<br />{4}<br />"
                    , lastRequestTime
                    , now
                    , (now - lastRequestTime).TotalSeconds
                    , GetSelfIpv4List()
                    , Request.Url
                    , currentState
                    , Server.MapPath(".")));
            }
            return;
        }



        //==============================================================================================================
        // 调试时使用，获取客户端ip 或 服务器ip
        //==============================================================================================================
        if (Request.QueryString["getuserip"] != null)
        {
            Response.Write(Request.UserHostAddress ?? string.Empty);
            return;
        }
        if (Request.QueryString["getip"] != null)
        {
            //获取当前服务器的ip地址
            string currentServerIp = GetSelfIpv4List();
            Response.Write(currentServerIp);
            return;
        }


        //==============================================================================================================
        // 工具接口：修改服务器在线状态
        //==============================================================================================================
        if (!string.IsNullOrEmpty(Request.QueryString["SetState"]))
        {
            if (string.IsNullOrEmpty(Request.QueryString["do"]))
            {
                Response.Write("请用工具设置上下线状态");
                return;
            }
            string clientip = Request.UserHostAddress ?? string.Empty;
            bool isIpOk = false;
            foreach (string item in WhiteIpList)
            {
                if (clientip.StartsWith(item))
                {
                    isIpOk = true;
                    break;
                }
            }
            if (!isIpOk)
            {
                Response.Write("您的IP没有权限设置上下线状态");
                return;
            }
            string tmp = Request.QueryString["SetState"];
            bool setState = string.IsNullOrEmpty(tmp) || tmp == "1" ||
                            tmp.Equals("true", StringComparison.OrdinalIgnoreCase) ||
                            tmp.Equals("online", StringComparison.OrdinalIgnoreCase);
            string msg = SetCurrentStatus(setState);
            if (!string.IsNullOrEmpty(msg))
            {
                Response.Write(msg);
                return;
            }
            currentState = setState ? ONLINE : OFFLINE;
            Response.Write("修改成功，当前状态：" + currentState);
            return;
        }


        //==============================================================================================================
        // 工具接口：读取服务器文件MD5，用于版本比对
        //==============================================================================================================
        if (!string.IsNullOrEmpty(Request.QueryString["md5"]))
        {
            DoGetMd5();
            return;
        }

        Response.StatusCode = (currentState == OFFLINE ? OFFLINE_CODE : ONLINE_CODE);
        Response.Write(currentState);
        Response.End();
    }

    /// <summary>
    /// 读取本机上下线状态
    /// </summary>
    /// <returns></returns>
    private static bool GetCurrentStatus()
    {
        if (!File.Exists(StatusSavePath))
            return true;
        lock(lockobj)
        {
            string content;
            using (StreamReader sr = new StreamReader(StatusSavePath, Encoding.UTF8))
            {
                content = sr.ReadLine() ?? "1";
            }
            return content == "1" || content == ONLINE;
        }
    }

    /// <summary>
    /// 设置本机上下线状态
    /// </summary>
    /// <returns></returns>
    private static string SetCurrentStatus(bool state)
    {
        try
        {
            string dir = Path.GetDirectoryName(StatusSavePath);
            if (dir != null && !Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }
            lock (lockobj)
            {
                using (StreamWriter sr = new StreamWriter(StatusSavePath, false, Encoding.UTF8))
                {
                    sr.Write(state ? "1" : "0");
                }
            }
            return null;
        }
        catch (Exception exp)
        {
            return "错误： " + exp.Message;
        }
    }


    private void DoGetMd5()
    {
        string dir = Request.Form["d"] ?? Request.QueryString["d"];
        if (dir == null || (dir = dir.Trim()).Length == 0)
            return;
        if (dir.Length == 2)
            dir += "\\"; // 处理e:这样的格式,因为e:是当前站点根目录，不是磁盘根目录
        // 防止出现 c:\\\\a.exe 或 c:/a.exe这样的路径,统一格式化成：c:\a.exe形式
        dir = Path.Combine(Path.GetDirectoryName(dir) ?? "", Path.GetFileName(dir) ?? "");

        //获取指定目录下所有文件的md5值，用于接口调用
        Dictionary<string, string> md5s = new Dictionary<string, string>();
        string err = GetAllFileMd5(dir, md5s, dir);
        Response.ContentType = "text/plain";
        if (!string.IsNullOrEmpty(err))
        {
            Response.Write("出错了," + err + "\r\n");
        }
        foreach (KeyValuePair<string, string> pair in md5s)
        {
            Response.Write(pair.Key + "," + pair.Value + "\r\n");
        }
    }

    /// <summary>
    /// 返回指定目录下的全部
    /// </summary>
    /// <param name="dirPath"></param>
    /// <param name="md5s"></param>
    /// <param name="root"></param>
    /// <returns></returns>
    static string GetAllFileMd5(string dirPath, Dictionary<string, string> md5s, string root)
    {
        if (string.IsNullOrEmpty(dirPath) || !Directory.Exists(dirPath))
        {
            return dirPath + " 目录不存在";
        }
        if (!dirPath.EndsWith("\\"))
        {
            dirPath += "\\";
        }
        if (dirPath.IndexOf(".svn", StringComparison.OrdinalIgnoreCase) >= 0 ||
            dirPath.IndexOf(".git", StringComparison.OrdinalIgnoreCase) >= 0 ||
            dirPath.IndexOf("\\configs\\", StringComparison.OrdinalIgnoreCase) >= 0 ||
            dirPath.IndexOf("\\logs\\", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return string.Empty; // 不比对svn或git目录
        }
        try
        {
            foreach (string file in Directory.GetFiles(dirPath))
            {
                md5s.Add(file.Replace(root, ""), GetMD5(file));
            }
            foreach (string dir in Directory.GetDirectories(dirPath))
            {
                string ret = GetAllFileMd5(dir, md5s, root);
                if (ret != string.Empty)
                {
                    return ret;
                }
            }
            return string.Empty;
        }
        catch (Exception exp)
        {
            return dirPath + " 子目录或文件列表获取失败:" + exp;
        }
    }
    static string GetMD5(string path)
    {
        try
        {
            using (MD5CryptoServiceProvider get_md5 = new MD5CryptoServiceProvider())
            using (FileStream get_file = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                return BitConverter.ToString(get_md5.ComputeHash(get_file)).Replace("-", "");
            }
        }
        catch (Exception exp)
        {
            return exp.Message;
        }
    }

    /// <summary>
    /// 获取本机所有IPV4地址列表
    /// </summary>
    /// <returns>本机所有IPV4地址列表，以分号分隔</returns>
    static string GetSelfIpv4List()
    {
        StringBuilder ips = new StringBuilder();
        try
        {
            IPHostEntry IpEntry = Dns.GetHostEntry(Dns.GetHostName());
            foreach (IPAddress ipa in IpEntry.AddressList)
            {
                if (ipa.AddressFamily == AddressFamily.InterNetwork)
                    ips.AppendFormat("{0};", ipa);
            }
        }
        catch (Exception)
        {
            // LogHelper.WriteCustom("获取本地ip错误" + ex, @"zIP\", false);
        }
        return ips.ToString();
    }

    /// <summary>
    /// 移除文件名中不可用的11个字符
    /// </summary>
    /// <param name="filenameNoDir"></param>
    /// <param name="replaceWith"></param>
    /// <returns></returns>
    static string ReplaceNonValidChars(string filenameNoDir, string replaceWith)
    {
        if (string.IsNullOrEmpty(filenameNoDir))
            return string.Empty;
        //替换这9个字符<>/\|:"*? 以及 回车换行
        return Regex.Replace(filenameNoDir, @"[\<\>\/\\\|\:""\*\?\r\n]", replaceWith, RegexOptions.Compiled);
    }

    /// <summary>
    /// 获取字符串指定的类型返回
    /// </summary>
    /// <param name="type"></param>
    /// <returns></returns>
    static Type GetType(string type)
    {
        type = (type ?? "").Trim();
        if (type.Length == 0)
        {
            return null;
        }
        try
        {
            if (nowAssembly == null)
            {
                int idx = type.LastIndexOf(".", StringComparison.Ordinal);
                if (idx > 0)
                {
                    string assemName = type.Substring(0, idx);
                    nowAssembly = Assembly.Load(assemName);
                }
            }
            if (nowAssembly == null)
            {
                return null;
            }
            return nowAssembly.GetType(type);
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// 获取指定类型里的静态公开字段值
    /// </summary>
    /// <param name="type"></param>
    /// <param name="fieldName"></param>
    /// <returns></returns>
    static object GetStaticField(Type type, string fieldName)
    {
        BindingFlags flags = BindingFlags.GetField | BindingFlags.Static | BindingFlags.Public;
        FieldInfo field = type.GetField(fieldName, flags);
        if (field != null)
        {
            return field.GetValue(null);
        }
        return null;
    }
</script>
