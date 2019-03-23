#ifndef STYLER_H
#define STYLER_H

#include <QObject>
#include <QVariant>

class Styler : public QObject
{
    Q_OBJECT
public:
    explicit Styler(QObject *parent = nullptr);

signals:

public slots:
    QVariant fnGetStylesList();
    void fnSetStyle(int iIndex);
    void fnSetStyle(QString sStyleName);
};

#endif // STYLER_H
