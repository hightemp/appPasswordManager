#include "clipboard.h"

Clipboard::Clipboard(QObject *parent) : QObject(parent)
{
}

void Clipboard::fnSetClipboard(QClipboard* poClipboard)
{
    this->poClipboard = poClipboard;
}

void Clipboard::fnCopy(QVariant sString)
{
    this->poClipboard->setText(sString.toString());
}
