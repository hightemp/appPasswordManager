#include "Styler.h"
//#include <QQuickStyle>
#include <QDebug>

Styler::Styler(QObject *parent) : QObject(parent)
{

}

QVariant Styler::fnGetStylesList()
{
    return QString("");// QQuickStyle::availableStyles();
}

void Styler::fnSetStyle(int iIndex)
{
    //qDebug() << "fnSetStyle" << QQuickStyle::availableStyles()[iIndex] << iIndex;
    //QQuickStyle::setStyle(QQuickStyle::availableStyles()[iIndex]);
}

void Styler::fnSetStyle(QString sStyleName)
{
    //QQuickStyle::setStyle(sStyleName);
}

