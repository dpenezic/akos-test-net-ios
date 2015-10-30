/*********************************************************************************
* Copyright 2013 appscape gmbh
* Copyright 2014-2015 SPECURE GmbH
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*   http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*********************************************************************************/

#pragma mark - Fixed test parameters

#define RMBT_TEST_CIPHER                SSL_RSA_WITH_RC4_128_MD5
#define RMBT_TEST_SOCKET_TIMEOUT_S      30.0

// In case of slow upload, we finalize the test even if this many seconds still haven't been received:
#define RMBT_TEST_UPLOAD_MAX_DISCARD_S  1.0

// Minimum number of seconds to wait after sending last chunk, before starting to discard.
#define RMBT_TEST_UPLOAD_MIN_WAIT_S     0.25

// Maximum number of seconds to wait for server reports after last chunk has been sent.
// After this interval we will close the socket and finish the test on first report received.
#define RMBT_TEST_UPLOAD_MAX_WAIT_S     3

// Measure and submit speed during test in these intervals
#define RMBT_TEST_SAMPLING_RESOLUTION_MS 250
