#include "encrypter.h"
#include <QDebug>

Encrypter::Encrypter(QObject *parent) : QObject(parent)
{

}

int Encrypter::fnEncrypt(QString sKey, QByteArray oByteArray, QByteArray &oResultByteArray)
{
    qDebug() << __FUNCTION__;

    if (sKey.length() == 0) {
        return -1;
    }
    if (oByteArray.length() == 0) {
        return -2;
    }

    //int iUnicodeLength = sizeof(ushort);

    for (int iIndex=0; iIndex<this->MAGIC_NUMBER.length(); iIndex++) {
        /*
        ushort* pcUnicodeChar = new ushort;
        *pcUnicodeChar = 0;
        *pcUnicodeChar = this->MAGIC_NUMBER[iIndex].unicode();
        for (int iUnicodeIndex=0; iUnicodeIndex<iUnicodeLength; iUnicodeIndex++) {
            oResultByteArray.append(((char*)pcUnicodeChar)[iUnicodeIndex] ^ sKey[iIndex % sKey.length()].unicode());
        }
        delete pcUnicodeChar;
        */
        oResultByteArray.append(this->MAGIC_NUMBER[iIndex].unicode() ^ sKey[iIndex % sKey.length()].unicode());
    }

    for (int iIndex=0; iIndex<oByteArray.length(); iIndex++) {
        oResultByteArray.append(oByteArray[iIndex] ^ sKey[iIndex % sKey.length()].unicode());
    }

    return 1;
}

int Encrypter::fnDecrypt(QString sKey, QByteArray oByteArray, QByteArray &oResultByteArray)
{
    qDebug() << __FUNCTION__;

    if (sKey.length() == 0) {
        return -1;
    }
    if (oByteArray.length() == 0) {
        return -2;
    }

    //int iUnicodeLength = sizeof(ushort);
    QString sMagicNumber;

    for (int iIndex=0; iIndex<this->MAGIC_NUMBER.length(); iIndex++) {
        /*
        ushort* pcUnicodeChar = new ushort;
        *pcUnicodeChar = 0;
        for (int iUnicodeIndex=0; iUnicodeIndex<iUnicodeLength; iUnicodeIndex++) {
            ((char*)pcUnicodeChar)[iUnicodeIndex] = oByteArray[iIndex*iUnicodeLength+iUnicodeIndex] ^ sKey[iIndex % sKey.length()].unicode();
        }
        sMagicNumber.append(QChar(*pcUnicodeChar));
        delete pcUnicodeChar;
        */
        sMagicNumber.append(oByteArray[iIndex] ^ sKey[iIndex % sKey.length()].unicode());
    }
    qDebug() << sMagicNumber;

    if (sMagicNumber != this->MAGIC_NUMBER) {
        return -3;
    }

    int iStartPosition = this->MAGIC_NUMBER.length();//*iUnicodeLength;
    for (int iIndex=iStartPosition; iIndex<oByteArray.length(); iIndex++) {
        oResultByteArray.append(oByteArray[iIndex] ^ sKey[(iIndex-iStartPosition) % sKey.length()].unicode());
    }
    qDebug() << oResultByteArray;
    return 1;
}
