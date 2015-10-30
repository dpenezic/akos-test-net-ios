AKOS Test Net iOS App
=====================

AKOS Test Net is an open source, multi-threaded bandwidth test used in [AKOS Test Net]. This repository contains the sources for the iOS App. For server and Android App sources, see [https://github.com/specure/akos-test-net].
It was developed by [SPECURE GmbH] financed by the [Agencija za komunikacijska omrežja in storitve Republike Slovenije (AKOS)] [AKOS].

Some parts of AKOS Test Net are released under the Apache-License, other parts under the MAME-License.

  [SPECURE GmbH]: https://www.specure.com/
  [AKOS Test Net]: https://www.akostest.net/
  [AKOS]: http://www.akos-rs.si/
  [Apache License, Version 2.0]: http://www.apache.org/licenses/LICENSE-2.0
  [MAME License]: http://mamedev.org/legal.html
  [https://github.com/specure/akos-test-net]: https://github.com/specure/akos-test-net

This iOS App is based on the RTR-Netztest, which was developed by [appscape] financed by the [Austrian Regulatory Authority for Broadcasting and Telecommunications (RTR)] [RTR].

  [appscape]: http://appscape.at/
  [RTR-Netztest]: http://netztest.at/
  [RTR]: http://www.rtr.at/
  [Apache License, Version 2.0]: http://www.apache.org/licenses/LICENSE-2.0
  [https://github.com/alladin-IT/open-rmbt]: https://github.com/alladin-IT/open-rmbt

Building
--------

Xcode 6.4 with iOS 8 SDK is required to build the AKOS Test Net iOS App.

Before building, you need to supply a correct Google Maps API key as well as a server parameters in `RMBTConfig.swift`.

Troubleshooting
---------------

* Make sure to fake location if testing via ios simulator

Third-party Libraries
---------------------

In addition Google Maps iOS SDK, AKOS Test Net iOS App uses several open source 3rd-party libraries that are under terms of a separate license:

* [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket), public domain license
* [AFNetworking](https://github.com/AFNetworking/AFNetworking), MIT license
* [BlocksKit](https://github.com/pandamonia/BlocksKit), MIT license
* [libextobjc](https://github.com/jspahrsummers/libextobjc), MIT license
* [TUSafariActivity](https://github.com/davbeck/TUSafariActivity), 2-clause BSD license
* [BCGenieEeffect](https://github.com/Ciechan/BCGenieEffect), MIT license
* [GCNetworkReachability](https://github.com/GlennChiu/GCNetworkReachability), MIT license
* [KINWebBrowser](https://github.com/dfmuir/KINWebBrowser), MIT license
* [KLCPopup](https://github.com/jmascia/KLCPopup), MIT license
* [SwiftTryCatch](https://github.com/williamFalcon/SwiftTryCatch), MIT license
* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD), [Custom license](https://github.com/TransitApp/SVProgressHUD/blob/master/LICENSE.txt)

For details, see `Pods/Pods-acknowledgements.markdown`.

