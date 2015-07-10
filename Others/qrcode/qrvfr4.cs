﻿using System;
namespace ThoughtWorks.QRCode.Codec
{
    public class qrvfr4
    {
        public static byte[] data = new byte[]{
            49,49,49,49,49,49,49,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,49,49,49,49,49,49,49,10,49,48,48,48,48,48
            ,49,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,49,48,48,48,48,48,49,10,49,48,49,49,49,48,49,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,48,49,49,49,48
            ,49,10,49,48,49,49,49,48,49,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,49,48,49,49,49,48,49,10,49,48,49,49
            ,49,48,49,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,49,48,49,49,49,48,49,10,49,48,48,48,48,48,49,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,48,48,48
            ,48,48,49,10,49,49,49,49,49,49,49,48,49,48,49,48,49,48,49,48
            ,49,48,49,48,49,48,49,48,49,48,49,49,49,49,49,49,49,10,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,10,48,48,48,48,48,48,49,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,10,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,10
            ,48,48,48,48,48,48,49,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,10,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,10,48,48,48,48,48,48,49,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,10,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,10,48,48,48,48
            ,48,48,49,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,10,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,10,48,48,48,48,48,48,49,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,10,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,10,48,48,48,48,48,48,49,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,10,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,10
            ,48,48,48,48,48,48,49,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,10,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,10,48,48,48,48,48,48,49,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,10,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,10,48,48,48,48
            ,48,48,49,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,49,49,49,49,49,48,48,48,48,10,48,48,48,48,48,48,48,48,49,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,48,48,48,49,48
            ,48,48,48,10,49,49,49,49,49,49,49,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,49,48,49,48,49,48,48,48,48,10,49,48
            ,48,48,48,48,49,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,49,48,48,48,49,48,48,48,48,10,49,48,49,49,49,48,49,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,49,49,49
            ,49,48,48,48,48,10,49,48,49,49,49,48,49,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,10
            ,49,48,49,49,49,48,49,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,10,49,48,48,48,48,48
            ,49,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,48,48,48,48,48,48,10,49,49,49,49,49,49,49,48,48,48,48,48
            ,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
            ,48,10
        };
    }
}
