package com.flashfla.utils
{
    import flash.xml.XMLDocument;
    import flash.xml.XMLNode;
    import flash.xml.XMLNodeType;

    public class HtmlUtil
    {
        public static function color(str:String, color:String):String
        {
            return "<font color=\"" + color + "\">" + str + "</font>";
        }

        public static function size(str:String, size:String):String
        {
            return "<font size=\"" + size + "\">" + str + "</font>";
        }

        public static function font(str:String, face:String):String
        {
            return "<font face=\"" + face + "\">" + str + "</font>";
        }

        public static function bold(str:String):String
        {
            return "<b>" + str + "</b>";
        }

        public static function escape(str:String):String
        {
            return XML(new XMLNode(XMLNodeType.TEXT_NODE, str)).toXMLString();
        }

        public static function unescape(str:String):String
        {
            try
            {
                return new XMLDocument(str).firstChild.nodeValue;
            }
            catch (_)
            {
                return str;
            }
        }
    }
}
