//
//  spottie_curl.c
//  Spottie
//
//  Created by Lee Jun Kit on 14/8/21.
//

#include "spottie_curl.h"

CURLcode curl_easy_setopt_string(CURL *curl, CURLoption option, const char *param) {
    return curl_easy_setopt(curl, option, param);
}
 
CURLcode curl_easy_setopt_bool(CURL *curl, CURLoption option, bool param) {
    return curl_easy_setopt(curl, option, param);
}
