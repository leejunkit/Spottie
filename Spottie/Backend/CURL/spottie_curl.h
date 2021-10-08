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

CURLcode curl_easy_setopt_long(CURL *curl, CURLoption option, long param);
CURLcode curl_easy_setopt_string(CURL *curl, CURLoption option, const char *param);
CURLcode curl_easy_setopt_bool(CURL *curl, CURLoption option, bool param);
CURLcode curl_easy_setopt_slist(CURL *handle, CURLoption option, struct curl_slist *param);
CURLcode curl_easy_setopt_func_write(CURL *curl, CURLoption option, curl_write_callback param);
CURLcode curl_easy_setopt_func_read(CURL *curl, CURLoption option, curl_read_callback param);
CURLcode curl_easy_setopt_pointer(CURL *curl, CURLoption option, void *param);
CURLcode curl_easy_getinfo_long(CURL *handle, CURLINFO option, int64_t *param);
CURLcode curl_easy_getinfo_string(CURL *handle, CURLINFO option, const char **param);
CURLcode curl_easy_getinfo_double(CURL *handle, CURLINFO option, double *param);

#endif /* spottie_curl_h */
