//
//  spottie_curl.c
//  Spottie
//
//  Created by Lee Jun Kit on 14/8/21.
//

#include "spottie_curl.h"

CURLcode curl_easy_setopt_long(CURL *curl, CURLoption option, long param) {
    return curl_easy_setopt(curl, option, param);
}

CURLcode curl_easy_setopt_string(CURL *curl, CURLoption option, const char *param) {
    return curl_easy_setopt(curl, option, param);
}
 
CURLcode curl_easy_setopt_bool(CURL *curl, CURLoption option, bool param) {
    return curl_easy_setopt(curl, option, param);
}

CURLcode curl_easy_setopt_slist(CURL *curl, CURLoption option, struct curl_slist *param) {
    return curl_easy_setopt(curl, option, param);
}

CURLcode curl_easy_setopt_func_write(CURL *curl, CURLoption option, curl_write_callback param) {
    return curl_easy_setopt(curl, option, param);
}

CURLcode curl_easy_setopt_func_read(CURL *curl, CURLoption option, curl_read_callback param) {
    return curl_easy_setopt(curl, option, param);
}

CURLcode curl_easy_setopt_pointer(CURL *curl, CURLoption option, void *param) {
    return curl_easy_setopt(curl, option, param);
}

CURLcode curl_easy_getinfo_long(CURL *handle, CURLINFO option, int64_t *param)
{
    return curl_easy_getinfo(handle, option, param);
}

CURLcode curl_easy_getinfo_string(CURL *handle, CURLINFO option, const char **param)
{
    return curl_easy_getinfo(handle, option, param);
}

CURLcode curl_easy_getinfo_double(CURL *handle, CURLINFO option, double *param)
{
    return curl_easy_getinfo(handle, option, param);
}
