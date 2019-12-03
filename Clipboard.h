#ifndef CLIPBOARD_H
#define CLIPBOARD_H

#include <QObject>
#include <QClipboard>
#include <QVariant>

class Clipboard : public QObject
{
    Q_OBJECT

protected:
    QClipboard* poClipboard;

public:
    explicit Clipboard(QObject *parent = nullptr);

    void fnSetClipboard(QClipboard* poClipboard);

signals:

public slots:
    void fnCopy(QVariant sString);
};

#endif // CLIPBOARD_H
