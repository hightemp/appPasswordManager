import QtQuick 2.9
import QtWebSockets 1.1

WebSocket {
    id: passwordSyncClient
    property string sCommand: ""
    property var fnCallBack
    property var fnErrorCallBack
    property string sStatus: "Status:"
    property string sHost;
    property string sPort;

    active: false

    onBinaryMessageReceived: {
        if (sCommand == "SYNC_0" || sCommand == "SYNC_1" || sCommand == "SYNC_2") {
            var iResult = oPasswordListModel.fnFromByteArray(message, {SYNC_0:0, SYNC_1:1, SYNC_2:2}[sCommand]);
            if (iResult == -3) {
                sStatus = "Status: "+sHost+":"+sPort+" - wrong password";
            }
            if (iResult == -2 || iResult == -1) {
                sStatus = "Status: "+sHost+":"+sPort+" - empty key or string";
            }
            if (iResult == 1) {
                oPasswordListModel.fnSave();
                sStatus = "Status: "+sHost+":"+sPort+" - synchronized";
            }
            if (fnCallBack)
                fnCallBack();
        }
    }

    onTextMessageReceived: {
        if (message=="AUTH_OK") {
            sendTextMessage(sCommand);

            if (sCommand == "SYNC_3" || sCommand == "SYNC_4" || sCommand == "SYNC_5") {
                sendBinaryMessage(oPasswordListModel.fnToByteArray());
            }
        }
        if (message=="AUTH_ERROR") {
            sStatus = "Status: "+sHost+":"+sPort+" - authorization error";
            if (fnCallBack)
                fnCallBack();
        }
        if (message=="SYNC_OK") {
            sStatus = "Status: "+sHost+":"+sPort+" - synchronized";
            if (fnCallBack)
                fnCallBack();
        }
        if (message=="SYNC_ERROR") {
            sStatus = "Status: "+sHost+":"+sPort+" - synchronization error";
            if (fnCallBack)
                fnCallBack();
        }
    }

    onStatusChanged: {
        console.log('onStatusChanged', status);
        if (status == WebSocket.Error) {
            connectionTimeout.stop();

            sStatus = "Error";
            if (fnErrorCallBack)
                fnErrorCallBack("Client error: "+sHost+":"+sPort+" - %1".arg(errorString));
        } else if (status == WebSocket.Open) {
            connectionTimeout.stop();

            sStatus = "Status: "+sHost+":"+sPort+" - connected";

            sendTextMessage("AUTH");
            sendBinaryMessage(oPasswordListModel.fnEncryptPassword());
        } else if (status == WebSocket.Connecting) {
            connectionTimeout.start();

            sStatus = "Status: "+sHost+":"+sPort+" - connecting..";
        }  else if (status == WebSocket.Closing) {
            //sStatus = "Status: "+sHost+":"+sPort+" - closing connection..";
        } else if (status == WebSocket.Closed) {
            //sStatus = "Status: "+sHost+":"+sPort+" - connection closed";
        }
    }
}
