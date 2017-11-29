<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Reflection" %>
<script language="C#" runat="server">
    /************************************************************************************/
    //��Global.asax.cs���������´��룺
    /*
        // ���һ���û����ʵ�ʱ��    
        public static DateTime LAST_ACCESS_TIME_KEY = DateTime.Now;
        // վ�����������������û����ʴ���
        public static int AccessCount = 0;
        void Application_EndRequest(object sender, EventArgs e)
        {
            string url = Request.Url.ToString().ToLower();
            // ��¼�ʱ�䣬�����ж�վ���Ƿ��û�ʹ���У���Щ�жϴ���ע��Ҫ���β���ҳ�棩
            if (url.IndexOf("iswebmon=", StringComparison.Ordinal) < 0 &&           // վ���س�����ʣ�����Ϊ�û�
                url.IndexOf("/checkipinfo.aspx", StringComparison.Ordinal) < 0 &&   // ǰ����ѯʱ������Ϊ�û�
                url.IndexOf("/z.aspx", StringComparison.Ordinal) < 0)       
            {
                LAST_ACCESS_TIME_KEY = DateTime.Now;
                Interlocked.Increment(ref AccessCount);
            }
     */
    //
    //ʹ��ע�⣺
    //1���޸��������LAST_ACCESS_TIME_KEYǰ��������ռ�
    //2���޸�WhiteIpList�����������������״̬��ip�б�����Ƿ��û�����
    /************************************************************************************/

    // ����״̬���浽���ļ���
    private static string SavePath  = Path.Combine(@"e:\upload", ReplaceNonValidChars(HttpContext.Current.Server.MapPath("."), "_") + ".onoffconfig");

    // Global.asax.cs��������������������ռ䣬���ں��淴���ȡ�������ʱ��
    private static string GlobalClassName = "Mike.ConfigsCenter.Web.WebApiApplication";

    private static List<string> _whiteIpList;
    /// <summary>
    /// ��������������״̬��ip�б�,�����ʵ����Ŀ�޸�ip
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
                        _whiteIpList.Add("127.");          // localhost���ص�ַ
                        _whiteIpList.Add("218.85.23.101"); // VPN����IP
                        _whiteIpList.Add("110.80.152.72"); // �칫����IP
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
    /// ���нӿڶ�д��������
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        //��ȡ��ǰ��������������״̬�������ȡ��������Ĭ��Ϊ����״̬
        string currentState = GetCurrentStatus() ? ONLINE : OFFLINE;
        DateTime now = DateTime.Now;

        //==============================================================================================================
        // ���߽ӿڣ�����״̬��ѯ�����ݵ�ǰ���������һ������ʱ���жϷ������Ƿ��Ѿ�����
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
                //�������ϴ�����ʱ��|��ǰʱ��|��ǰ������������������״̬
                Response.Write(string.Format("{0}|{1}|{2}|{3}", lastRequestTime.ToString(ymd), now.ToString(ymd), currentState, accessCount));
            }
            else
            {
                Response.Write(string.Format("��ǰ��������״̬Ϊ��{5}<br />�������ϴ�����ʱ��Ϊ��{0}����ǰʱ��Ϊ��{1}��" +
                                             "����ˣ�<span style=\"font-weight:bold; color:red;\">{2}</span> ��<br />{3}<br />{4}<br />"
                    , lastRequestTime
                    , now
                    , (now - lastRequestTime).TotalSeconds
                    , GetSelfIpv4List()
                    , Request.Url
                    , currentState
                    ));
            }
            return;
        }



        //==============================================================================================================
        // ����ʱʹ�ã���ȡ�ͻ���ip �� ������ip
        //==============================================================================================================
        if (Request.QueryString["getuserip"] != null)
        {
            Response.Write(Request.UserHostAddress ?? string.Empty);
            return;
        }
        if (Request.QueryString["getip"] != null)
        {
            //��ȡ��ǰ��������ip��ַ
            string currentServerIp = GetSelfIpv4List();
            Response.Write(currentServerIp);
            return;
        }


        //==============================================================================================================
        // ���߽ӿڣ��޸ķ���������״̬
        //==============================================================================================================
        if (!string.IsNullOrEmpty(Request.QueryString["SetState"]))
        {
            if (string.IsNullOrEmpty(Request.QueryString["do"]))
            {
                Response.Write("���ù�������������״̬");
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
                Response.Write("����IPû��Ȩ������������״̬");
                return;
            }
            string tmp = Request.QueryString["SetState"];
            bool setState = string.IsNullOrEmpty(tmp) || tmp == "1" ||
                            tmp.Equals("true", StringComparison.OrdinalIgnoreCase) ||
                            tmp.Equals("online", StringComparison.OrdinalIgnoreCase);
            SetCurrentStatus(setState);
            currentState = setState ? ONLINE : OFFLINE;
            Response.Write("�޸ĳɹ�����ǰ״̬��" + currentState);
            return;
        }

        Response.StatusCode = (currentState == OFFLINE ? OFFLINE_CODE : ONLINE_CODE);
        Response.Write(currentState);
        Response.End();
    }

    /// <summary>
    /// ��ȡ����������״̬
    /// </summary>
    /// <returns></returns>
    private static bool GetCurrentStatus()
    {
        if (!File.Exists(SavePath))
            return true;
        lock(lockobj)
        {
            string content;
            using (StreamReader sr = new StreamReader(SavePath, Encoding.UTF8))
            {
                content = sr.ReadLine() ?? "1";
            }
            return content == "1" || content == ONLINE;
        }
    }

    /// <summary>
    /// ���ñ���������״̬
    /// </summary>
    /// <returns></returns>
    private static void SetCurrentStatus(bool state)
    {
        lock (lockobj)
        {
            using (StreamWriter sr = new StreamWriter(SavePath, false, Encoding.UTF8))
            {
                sr.Write(state ? "1" : "0");
            }
        }
    }


    /// <summary>
    /// ��ȡ��������IPV4��ַ�б�
    /// </summary>
    /// <returns>��������IPV4��ַ�б��Էֺŷָ�</returns>
    public static string GetSelfIpv4List()
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
            // LogHelper.WriteCustom("��ȡ����ip����" + ex, @"zIP\", false);
        }
        return ips.ToString();
    }

    /// <summary>
    /// �Ƴ��ļ����в����õ�11���ַ�
    /// </summary>
    /// <param name="filenameNoDir"></param>
    /// <param name="replaceWith"></param>
    /// <returns></returns>
    static string ReplaceNonValidChars(string filenameNoDir, string replaceWith)
    {
        if (string.IsNullOrEmpty(filenameNoDir))
            return string.Empty;
        //�滻��9���ַ�<>/\|:"*? �Լ� �س�����
        return Regex.Replace(filenameNoDir, @"[\<\>\/\\\|\:""\*\?\r\n]", replaceWith, RegexOptions.Compiled);
    }

    /// <summary>
    /// ��ȡ�ַ���ָ�������ͷ���
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
    /// ��ȡָ��������ľ�̬�����ֶ�ֵ
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
