import dbus
import dbus.service
import dbus.mainloop.glib
import gobject
import threading
from queue import Queue

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
    def fetch_loop(self, notifications):
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        session_bus = dbus.SessionBus()
        name = dbus.service.BusName("org.freedesktop.Notifications", session_bus)
        fetcher = NotificationFetcher(session_bus, notifications)

        gobject.threads_init()
        context = gobject.MainLoop().get_context()

        while True:
            print('[gobject iteration]')
            context.iteration(True)

    def loop(self, events=None):
        notifications = Queue()

        fetcher_thread = threading.Thread(
            target=self.fetch_loop, args=(notifications,)
        )
        fetcher_thread.daemon = True
        fetcher_thread.start()

        while True:
            print(notifications.get())
