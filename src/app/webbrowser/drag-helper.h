/*
 * Copyright 2016 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __DRAGHELPER_H__
#define __DRAGHELPER_H__

#include <QQuickItem>
#include <QMouseEvent>
#include <QRect>

class DragHelper : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(Qt::DropAction expectedAction READ expectedAction WRITE setExpectedAction NOTIFY expectedActionChanged)
    Q_PROPERTY(QString mimeType READ mimeType WRITE setMimeType NOTIFY mimeTypeChanged)
    Q_PROPERTY(QString previewUrl READ previewUrl WRITE setPreviewUrl NOTIFY previewUrlChanged)
    Q_PROPERTY(QQuickItem* source READ source WRITE setSource NOTIFY sourceChanged)
public:
    DragHelper();
    bool active() { return m_active; }
    Qt::DropAction expectedAction() { return m_expected_action; }
    QString mimeType() { return m_mime_type; }
    QString previewUrl() { return m_preview_url; }
    QQuickItem *source() { return m_source; }
signals:
    void activeChanged();
    void expectedActionChanged();
    void mimeTypeChanged();
    void previewUrlChanged();
    void sourceChanged();
public slots:
    Q_INVOKABLE Qt::DropAction execDrag(QString tabId);
    void setActive(bool active);
    void setExpectedAction(Qt::DropAction expectedAction);
    void setMimeType(QString mimeType);
    void setPreviewUrl(QString previewUrl);
    void setSource(QQuickItem *source);
private:
    bool m_active;
    Qt::DropAction m_expected_action;
    QString m_mime_type;
    QString m_preview_url;
    QQuickItem *m_source;
};

#endif // __DRAGHELPER_H__

