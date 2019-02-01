#ifndef ENCRYPTER_H
#define ENCRYPTER_H

#include <QObject>

class Encrypter : public QObject
{
    Q_OBJECT
public:
    const QString MAGIC_NUMBER = "123456";

    explicit Encrypter(QObject *parent = nullptr);

signals:

public slots:
    int fnEncrypt(QString sKey, QByteArray oByteArray, QByteArray &oResultByteArray);
    int fnDecrypt(QString sKey, QByteArray oByteArray, QByteArray &oResultByteArray);
};

#endif // ENCRYPTER_H
