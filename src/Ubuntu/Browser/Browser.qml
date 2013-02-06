/*
 * Copyright 2013 Canonical Ltd.
 *
 * This file is part of ubuntu-browser.
 *
 * ubuntu-browser is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * ubuntu-browser is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import Ubuntu.Components 0.1

FocusScope {
    id: browser

    property bool chromeless: false
    property alias url: webview.url
    // title is a bound property instead of an alias because of QTBUG-29141
    property string title: webview.title

    focus: true

    WebView {
        id: webview

        anchors.fill: parent

        focus: true

        // iOS 5.0’s iPhone user agent
        experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"

        experimental.preferences.navigatorQtObjectEnabled: true
        experimental.onMessageReceived: {
            var data = JSON.parse(message.data)
            if ('event' in data) {
                var event = data.event
                delete data.event
                if (event === 'longpress') {
                    var scale = webview.experimental.test.contentsScale * webview.experimental.test.devicePixelRatio
                    selection.rect.x = data.left * scale
                    selection.rect.y = data.top * scale
                    selection.rect.width = data.width * scale
                    selection.rect.height = data.height * scale
                    selection.visible = true
                    console.log("Selected HTML:", data.html)
                }
            }
        }

        onUrlChanged: {
            if (!browser.chromeless) {
                chromeLoader.item.url = url
            }
        }

        onActiveFocusChanged: {
            if (activeFocus) {
                revealingBar.hide()
            }
        }

        onLoadingChanged: {
            if (loadRequest.status === WebView.LoadSucceededStatus) {
                var query = (function() {
                    var doc = document.documentElement;
                    doc.addEventListener('touchstart', function(event) {
                        this.currentTouch = event.touches[0];
                        this.longpressObserver = setTimeout(function(x, y) {
                            var element = document.elementFromPoint(x, y);
                            var data = element.getBoundingClientRect();
                            data['event'] = 'longpress';
                            data['html'] = element.outerHTML;
                            navigator.qt.postMessage(JSON.stringify(data));
                        }, 800, this.currentTouch.clientX, this.currentTouch.clientY);
                    });
                    doc.addEventListener('touchend', function(event) {
                        clearTimeout(this.longpressObserver);
                        delete this.longpressObserver;
                        delete this.currentTouch;
                    });
                    doc.addEventListener('touchmove', function(event) {
                          var touch = event.changedTouches[0];
                          var distance = Math.sqrt(Math.pow(touch.clientX - this.currentTouch.clientX, 2) + Math.pow(touch.clientY - this.currentTouch.clientY, 2));
                          if (distance > 3) {
                              clearTimeout(this.longpressObserver);
                              delete this.longpressObserver;
                              delete this.currentTouch;
                          }
                    });
                })
                webview.experimental.evaluateJavaScript('(' + query.toString() + ')()')
            }
        }
    }

    Selection {
        id: selection
        anchors.fill: webview
        visible: false
    }

    Scrollbar {
        flickableItem: webview
        align: Qt.AlignTrailing
    }

    Scrollbar {
        flickableItem: webview
        align: Qt.AlignBottom
    }

    RevealingBar {
        id: revealingBar
        enabled: !browser.chromeless
        contents: chromeLoader.item
    }

    Loader {
        id: chromeLoader

        active: !browser.chromeless
        source: "Chrome.qml"

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: osk.top
        height: units.gu(8)

        Binding {
            target: chromeLoader.item
            property: "canGoBack"
            value: webview.canGoBack
        }

        Binding {
            target: chromeLoader.item
            property: "canGoForward"
            value: webview.canGoForward
        }

        Connections {
            target: chromeLoader.item
            onGoBackClicked: webview.goBack()
            onGoForwardClicked: webview.goForward()
            onUrlValidated: {
                browser.url = url
                webview.forceActiveFocus()
            }
        }
    }

    KeyboardRectangle {
        id: osk
    }
}
