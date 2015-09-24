#!/usr/bin/python3

import dbus
import dbus.service
import dbus.mainloop.glib
import gobject
import threading
import html.parser
import re
from queue import Queue, Empty

from visual import PanelVisual
from panel_strip import PanelStrip

# very heavily modified code from statnot (https://github.com/halhen/statnot)
class NotificationFetcher(dbus.service.Object):
    def __init__(self, session_bus, notifications):
        self.notifications = notifications
        self.last_pseudo_id = 1
        super().__init__(session_bus, '/org/freedesktop/Notifications')

    @dbus.service.method("org.freedesktop.Notifications",
                     in_signature='susssasa{ss}i',
                     out_signature='u')
    def Notify(self, app_name, notification_id, app_icon,
               summary, body, actions, hints, expire_timeout):
        if not notification_id:
            notification_id = self.last_pseudo_id
            self.last_pseudo_id += 1

        data = {
            'app_name': app_name,
            'notification_id': notification_id,
            'app_icon': app_icon,
            'summary': summary,
            'body': body,
            'actions': actions,
            'hints': hints,
            'expire_timeout': expire_timeout
        }
        self.notifications.put(data)

        return notification_id

    @dbus.service.method("org.freedesktop.Notifications", in_signature='', out_signature='as')
    def GetCapabilities(self):
        return "body"

    @dbus.service.signal('org.freedesktop.Notifications', signature='uu')
    def NotificationClosed(self, id_in, reason_in):
        pass

    @dbus.service.method("org.freedesktop.Notifications", in_signature='u', out_signature='')
    def CloseNotification(self, id):
        pass

    @dbus.service.method("org.freedesktop.Notifications", in_signature='', out_signature='ssss')
    def GetServerInformation(self):
        return ("ui", "http://github.com/DexterLB/ui", "0.0.1", "1")

class NotificationMonitor:
    default_timeout = 3
    max_timeout = 5

    def __init__(self):
        self.history = []
        self.history_index = 0
        self.stacked_notifications = 0
        self.dismiss_timer = None

    def remove_html(self, text):
        return html.parser.HTMLParser().unescape(re.sub(r'<[^>]*?>', '', text))

    def render_notification(self, notification):
        info = PanelStrip('notification')
        if not notification:
            return info

        if self.stacked_notifications > 1:
            info.text(
                '[' + str(self.stacked_notifications) + ']',
                background=PanelVisual.urgent
            ).text(' ')
        info.text(
            self.remove_html(notification['summary']),
            colour=PanelVisual.active
        ).text(' ')
        info.text(self.remove_html(notification['body']))
        return info

    def fetch_loop(self, notifications):
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        session_bus = dbus.SessionBus()
        name = dbus.service.BusName("org.freedesktop.Notifications", session_bus)
        fetcher = NotificationFetcher(session_bus, notifications)

        gobject.threads_init()
        context = gobject.MainLoop().get_context()

        while True:
            context.iteration(True)

    def dismiss_after(self, timeout, events):
        if self.dismiss_timer:
            self.dismiss_timer.cancel()

        self.dismiss_timer = threading.Timer(
            timeout,
            lambda: self.dismiss_notification(events)
        )
        self.dismiss_timer.start()

    def show_notification(self, notification, events):
        if notification['expire_timeout'] > 0:
            timeout = min(
                notification['expire_timeout'] / float(1000),
                self.max_timeout
            )
        else:
            timeout = self.default_timeout

        self.dismiss_after(timeout, events)
        events.put(self.render_notification(notification))

    def post_notification(self, notification, events):
        self.history.append(notification)
        self.stacked_notifications += 1
        self.show_notification(notification, events)


    def dismiss_notification(self, events):
        self.history_index = len(self.history)
        self.stacked_notifications = 0
        events.put(self.render_notification(None))

    def history_next(self, events):
        if not self.history:
            return
        self.history_index -= 1
        if self.history_index < 0:
            self.history_index = len(self.history) - 1

        self.show_notification(self.history[self.history_index], events)

    def loop(self, events=None):
        notifications = Queue()

        fetcher_thread = threading.Thread(
            target=self.fetch_loop, args=(notifications,)
        )
        fetcher_thread.daemon = True
        fetcher_thread.start()

        while True:
            self.post_notification(notifications.get(), events)
