#include "encrypter.h"
#include <QDebug>
#include <QBitArray>
#include <math.h>


Encrypter::Encrypter(QObject *parent) : QObject(parent)
{

}

int Encrypter::fnEncrypt(QString sKey, QByteArray oData, QByteArray &oResult)
{
    qDebug() << __FUNCTION__;

    if (sKey.length() == 0) {
        return -1;
    }
    if (oData.length() == 0) {
        return -2;
    }

    int iRounds = 1;
    QByteArray oKeyByteArray = sKey.toUtf8();
    oResult = oData;

    oResult.insert(0, oKeyByteArray);

    for (int iRoundIndex=0; iRoundIndex<iRounds; iRoundIndex++) {
        for (int iKeyIndex=0; iKeyIndex<oKeyByteArray.size(); iKeyIndex++) {
            int aiMethods[] = {0, 4, 1, 4, 2, 4, 3, 4};

            for (int iMethodIndex=0; iMethodIndex<5; iMethodIndex++) {
                int iLineLength = oKeyByteArray[iKeyIndex] % 10 + 5;
                unsigned char cByte = 0;

                switch (aiMethods[iMethodIndex]) {
                    case 0:
                        for (int iLineIndex=0; iLineIndex<ceil(oResult.size()/iLineLength); iLineIndex++) {
                            this->fnLeftByteShift(oResult, iLineIndex, iLineLength, oKeyByteArray[iKeyIndex]+iMethodIndex);
                        }
                    break;
                    case 1:
                        for (int iLineIndex=0; iLineIndex<ceil(oResult.size()/iLineLength); iLineIndex++) {
                            this->fnRightByteShift(oResult, iLineIndex, iLineLength, oKeyByteArray[iKeyIndex]+iMethodIndex);
                        }
                    break;
                    case 2:
                        for (int iIndex=0; iIndex<oResult.size(); iIndex++) {
                            cByte = oResult[iIndex];
                            this->fnLeftBitShift(cByte, oKeyByteArray[iKeyIndex]+iMethodIndex);
                            oResult[iIndex] = cByte;
                        }
                    break;
                    case 3:
                        for (int iIndex=0; iIndex<oResult.size(); iIndex++) {
                            cByte = oResult[iIndex];
                            this->fnRightBitShift(cByte, oKeyByteArray[iKeyIndex]+iMethodIndex);
                            oResult[iIndex] = cByte;
                        }
                    break;
                    case 4:
                        for (int iIndex=0; iIndex<oResult.size(); iIndex++) {
                            oResult[iIndex] = oResult[iIndex] ^ oKeyByteArray[(iIndex+iMethodIndex) % oKeyByteArray.size()];
                        }
                    break;
                }
            }
        }
    }

    return 1;
}

int Encrypter::fnDecrypt(QString sKey, QByteArray oData, QByteArray &oResult)
{
    qDebug() << __FUNCTION__;

    if (sKey.length() == 0) {
        return -1;
    }
    if (oData.length() == 0) {
        return -2;
    }

    int iRounds = 1;
    QByteArray oKeyByteArray = sKey.toUtf8();
    oResult = oData;

    for (int iRoundIndex=0; iRoundIndex<iRounds; iRoundIndex++) {
        for (int iKeyIndex=oKeyByteArray.size()-1; iKeyIndex>=0; iKeyIndex--) {
            int aiMethods[] = {0, 4, 1, 4, 2, 4, 3, 4};

            for (int iMethodIndex=4; iMethodIndex>=0; iMethodIndex--) {
                int iLineLength = oKeyByteArray[iKeyIndex] % 10 + 5;
                unsigned char cByte = 0;

                switch (aiMethods[iMethodIndex]) {
                    case 1:
                        for (int iLineIndex=0; iLineIndex<ceil(oResult.size()/iLineLength); iLineIndex++) {
                            this->fnLeftByteShift(oResult, iLineIndex, iLineLength, oKeyByteArray[iKeyIndex]+iMethodIndex);
                        }
                    break;
                    case 0:
                        for (int iLineIndex=0; iLineIndex<ceil(oResult.size()/iLineLength); iLineIndex++) {
                            this->fnRightByteShift(oResult, iLineIndex, iLineLength, oKeyByteArray[iKeyIndex]+iMethodIndex);
                        }
                    break;
                    case 3:
                        for (int iIndex=0; iIndex<oResult.size(); iIndex++) {
                            cByte = oResult[iIndex];
                            this->fnLeftBitShift(cByte, oKeyByteArray[iKeyIndex]+iMethodIndex);
                            oResult[iIndex] = cByte;
                        }
                    break;
                    case 2:
                        for (int iIndex=0; iIndex<oResult.size(); iIndex++) {
                            cByte = oResult[iIndex];
                            this->fnRightBitShift(cByte, oKeyByteArray[iKeyIndex]+iMethodIndex);
                            oResult[iIndex] = cByte;
                        }
                    break;
                    case 4:
                        for (int iIndex=0; iIndex<oResult.size(); iIndex++) {
                            oResult[iIndex] = oResult[iIndex] ^ oKeyByteArray[(iIndex+iMethodIndex) % oKeyByteArray.size()];
                        }
                    break;
                }
            }
        }
    }

    QByteArray oExtractedKeyByteArray = oResult.mid(0, sKey.length());
    oResult.remove(0, sKey.length());

    if (oExtractedKeyByteArray != oKeyByteArray) {
        return -3;
    }

    return 1;
}

void Encrypter::fnLeftByteShift(QByteArray &oData, unsigned int iLineNumber, unsigned int iLineLength, unsigned int iShift)
{
    int iLinesCount = floor(oData.size() / iLineLength);
    int iAllLinesCount = ceil(oData.size() / iLineLength);
    iLineNumber = iLineNumber % iAllLinesCount;
    int iPosition = iLineNumber*iLineLength;
    int iNextLinePosition = (iLineNumber+1)*iLineLength;

    if (iNextLinePosition>oData.size()) {
        int iCurrentLineLength = oData.size() % iPosition + 1;
        iShift = iShift % iCurrentLineLength;

        if (iShift==0)
            return;

        if (iCurrentLineLength==1)
            return;

        for (int iIndex=0; iIndex<iShift; iIndex++) {
            unsigned int iTemp = oData[iPosition];
            for (int iShiftIndex=iPosition+1; iShiftIndex<iPosition+iCurrentLineLength; iShiftIndex++) {
                oData[iShiftIndex-1] = oData[iShiftIndex];
            }
            oData[iPosition+iCurrentLineLength-1] = iTemp;
        }
    } else {
        iShift = iShift % iLineLength;

        if (iShift==0)
            return;

        for (int iIndex=0; iIndex<iShift; iIndex++) {
            unsigned int iTemp = oData[iPosition];
            for (int iShiftIndex=iPosition+1; iShiftIndex<iNextLinePosition; iShiftIndex++) {
                oData[iShiftIndex-1] = oData[iShiftIndex];
            }
            oData[iNextLinePosition-1] = iTemp;
        }
    }
}

void Encrypter::fnRightByteShift(QByteArray &oData, unsigned int iLineNumber, unsigned int iLineLength, unsigned int iShift)
{
    int iLinesCount = floor(oData.size() / iLineLength);
    int iAllLinesCount = ceil(oData.size() / iLineLength);
    iLineNumber = iLineNumber % iAllLinesCount;
    int iPosition = iLineNumber*iLineLength;
    int iNextLinePosition = (iLineNumber+1)*iLineLength;

    if (iNextLinePosition>oData.size()) {
        int iCurrentLineLength = oData.size() % iPosition + 1;
        iShift = iShift % iCurrentLineLength;

        if (iShift==0)
            return;

        if (iCurrentLineLength==1)
            return;

        for (int iIndex=0; iIndex<iShift; iIndex++) {
            unsigned int iTemp = oData[iPosition+iCurrentLineLength-1];
            for (int iShiftIndex=iPosition+iCurrentLineLength-2; iShiftIndex>=iPosition; iShiftIndex--) {
                oData[iShiftIndex+1] = oData[iShiftIndex];
            }
            oData[iPosition] = iTemp;
        }
    } else {
        iShift = iShift % iLineLength;

        if (iShift==0)
            return;

        for (int iIndex=0; iIndex<iShift; iIndex++) {
            unsigned int iTemp = oData[iNextLinePosition-1];
            for (int iShiftIndex=iNextLinePosition-2; iShiftIndex>=iPosition; iShiftIndex--) {
                oData[iShiftIndex+1] = oData[iShiftIndex];
            }
            oData[iPosition] = iTemp;
        }
    }
}

void Encrypter::fnLeftBitShift(unsigned char &ucByte, unsigned int iShift)
{
    iShift = iShift % 7 + 1;

    if (iShift==0)
        return;

    ucByte = (ucByte << iShift) | (ucByte >> (8 - iShift));
}

void Encrypter::fnRightBitShift(unsigned char &ucByte, unsigned int iShift)
{
    iShift = iShift % 7 + 1;

    if (iShift==0)
        return;

    ucByte = (ucByte >> iShift) | (ucByte << (8 - iShift));
}

