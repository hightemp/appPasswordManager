import QtQuick 2.9
import QtWebSockets 1.1

WebSocketServer {
    id: passwordSyncServer

    property var aClients: [];

    listen: false
    accept: true
    //host: ""
    //port: 3002

    onClientConnected: {
        aClients.push({ bAuthorized: false, sCommand: "" });
        var iClientId = aClients.length - 1;

        webSocket
            .onTextMessageReceived
            .connect(function(sCommand)
            {
                console.log("sCommand: "+sCommand);
                aClients[iClientId].sCommand = sCommand;

                if (aClients[iClientId].bAuthorized) {
                    console.log("aClients[iClientId].bAuthorized ", iClientId, aClients[iClientId].bAuthorized);

                    if (sCommand == "SYNC_0" || sCommand == "SYNC_1" || sCommand == "SYNC_2") {
                        webSocket.sendBinaryMessage(oPasswordListModel.fnToByteArray());
                    }
                }
            });

        webSocket
            .onBinaryMessageReceived
            .connect(function(sMessage)
            {
                var sCommand = aClients[iClientId].sCommand;

                console.log("onBinaryMessageReceived - sCommand: "+sCommand);

                if (sCommand == "AUTH") {
                    if (oPasswordListModel.fnCheckPassword(sMessage)) {
                        aClients[iClientId].bAuthorized = true;
                        webSocket.sendTextMessage("AUTH_OK");
                        console.log("sendTextMessage AUTH_OK");
                    } else {
                        webSocket.sendTextMessage("AUTH_ERROR");
                        console.log("sendTextMessage AUTH_ERROR");
                    }
                }
                if (aClients[iClientId].bAuthorized) {
                    if (sCommand == "SYNC_3" || sCommand == "SYNC_4" || sCommand == "SYNC_5") {
                        var iResult = oPasswordListModel.fnFromByteArray(sMessage, {SYNC_3:0, SYNC_4:1, SYNC_5:2}[sCommand]);
                        if (iResult != 1) {
                            webSocket.sendTextMessage("SYNC_ERROR");
                        }
                        if (iResult == 1) {
                            oPasswordListModel.fnSave();
                            webSocket.sendTextMessage("SYNC_OK");
                        }
                    }
                }
            });
    }

    onErrorStringChanged: {
        stackView.settingsPageServerStatusLabelText = "Server status: Error "+errorString
    }

    onHostChanged: {
        console.log("onHostChanged", host);
    }

    onPortChanged: {
        console.log("onPortChanged", port);
    }

    onListenChanged: {
        if (listen) {
            stackView.settingsPageServerStatusLabelText = "Server status: listening "+host+":"+port;
        } else {
            stackView.settingsPageServerStatusLabelText = "Server status: stoped";
        }
        console.log(stackView.settingsPageServerStatusLabelText);
    }
}
