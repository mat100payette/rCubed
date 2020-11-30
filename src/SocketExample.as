
package
{
    import flash.display.Sprite;

    public class SocketExample extends Sprite
    {
        private var socket:CustomSocket;

        public function SocketExample()
        {
            socket = new CustomSocket("localhost", 7552);
        }
    }
}

import flash.errors.*;
import flash.events.*;
import flash.net.Socket;

class CustomSocket extends Socket
{
    private var response:String;

    public function CustomSocket(host:String = null, port:uint = 0)
    {
        super();
        configureListeners();
        if (host && port)
        {
            super.connect(host, port);
        }
    }

    private function configureListeners():void
    {
        addEventListener(Event.CLOSE, closeHandler);
        addEventListener(Event.CONNECT, connectHandler);
        addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
    }

    private function writeln(str:String):void
    {
        str += "\n";
        try
        {
            writeUTFBytes(str);
        }
        catch (e:IOError)
        {
            trace(e);
        }
    }

    private function sendRequest():void
    {
        trace("connected to server!");
        response = "";
        writeln("world!\r\n");
        flush();
    }

    private function readResponse():void
    {
        var str:String = readUTFBytes(bytesAvailable);
        response += str;
    }

    private function closeHandler(event:Event):void
    {
        trace("closeHandler: " + event);
        trace(response.toString());
    }

    private function connectHandler(event:Event):void
    {
        trace("connectHandler: " + event);
        sendRequest();
    }

    private function ioErrorHandler(event:IOErrorEvent):void
    {
        trace("ioErrorHandler: " + event);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void
    {
        trace("securityErrorHandler: " + event);
    }

    private function socketDataHandler(event:ProgressEvent):void
    {
        trace("socketDataHandler: " + event);
        readResponse();
    }
}
