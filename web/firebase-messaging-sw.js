navigator.serviceWorker.register(workerFileName, {scope: "/"})
    .then(
    function (reg) {
        var serviceWorker;
        if (reg.installing) {
            serviceWorker = reg.installing;
            // console.log('Service worker installing');
        } else if (reg.waiting) {
            serviceWorker = reg.waiting;
            // console.log('Service worker installed & waiting');
        } else if (reg.active) {
            serviceWorker = reg.active;
            // console.log('Service worker active');
        }

        if (serviceWorker) {
            console.log("sw current state", serviceWorker.state);
            if (serviceWorker.state == "activated") {
                //If push subscription wasnt done yet have to do here
                console.log("sw already activated - Do watever needed here");
            }
            serviceWorker.addEventListener("statechange", function(e) {
                console.log("sw statechange : ", e.target.state);
                if (e.target.state == "activated") {
                    // use pushManger for subscribing here.
                    console.log("Just now activated. now we can subscribe for push notification")
                    subscribeForPushNotification(reg);
                }
            });
        }
    },
    function (err) {
        console.error('unsuccessful registration with ', workerFileName, err);
    }
);