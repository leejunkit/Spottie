//
//  spottie_curl.h
//  Spottie
//
//  Created by Lee Jun Kit on 14/8/21.
//

#ifndef spottie_curl_h
#define spottie_curl_h

#include <stdbool.h>
#include <curl/curl.h>

CURLcode curl_easy_setopt_string(CURL *curl, CURLoption option, const char *param);
CURLcode curl_easy_setopt_bool(CURL *curl, CURLoption option, bool param);

#endif /* spottie_curl_h */
