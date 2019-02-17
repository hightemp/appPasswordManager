#ifndef ENCRYPTER_H
#define ENCRYPTER_H

#include <QObject>

class Encrypter : public QObject
{
    Q_OBJECT
public:
    explicit Encrypter(QObject *parent = nullptr);

signals:

public slots:
    int fnEncrypt(QString sKey, QByteArray &oData, QByteArray &oResult);
    int fnDecrypt(QString sKey, QByteArray &oData, QByteArray &oResult);
    void fnLeftByteShift(QByteArray &oData, unsigned int iLineNumber, unsigned int iLineLength, unsigned int iShift);
    void fnRightByteShift(QByteArray &oData, unsigned int iLineNumber, unsigned int iLineLength, unsigned int iShift);
    void fnLeftBitShift(unsigned char &ucByte, unsigned int iShift);
    void fnRightBitShift(unsigned char &ucByte, unsigned int iShift);
};

#endif // ENCRYPTER_H
