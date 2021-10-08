//
//  CurlClient.swift
//  Spottie
//
//  Created by Lee Jun Kit on 19/8/21.
//

import Foundation

class CurlReceivedData {
    var data: Data?
    init() {}
}

class CurlBodyData {
    var data: Data
    var bytesLeftToCopy: Int
    init(_ d: Data) {
        data = d
        bytesLeftToCopy = d.count
    }
}

enum CurlError: Error {
    case unknown
}

struct CurlClient {
    let socketPath: String
    let queue = DispatchQueue(label: "ljk.spottie.curl", qos: .userInteractive)
    let curl = curl_easy_init()
    let readFunc: curl_read_callback = { (buffer, size, num, p) -> Int in
        let wrapper = Unmanaged<CurlBodyData>.fromOpaque(p!).takeRetainedValue()
        let bufferSize = size * num
        
        var numBytesToCopy = wrapper.bytesLeftToCopy
        if numBytesToCopy == 0 {
            Unmanaged<CurlBodyData>.fromOpaque(p!).release()
            return 0
        }
        
        if numBytesToCopy > bufferSize {
            numBytesToCopy = bufferSize
        }
        
        // perform the copy
        let start = wrapper.data.count - wrapper.bytesLeftToCopy
        let range = start..<(start+numBytesToCopy)
        let bufferPointer = UnsafeMutableRawBufferPointer(start: buffer, count: bufferSize)
        let numBytesCopied = wrapper.data.copyBytes(to: bufferPointer, from: range)
        
        // update the state
        wrapper.bytesLeftToCopy = wrapper.bytesLeftToCopy - numBytesCopied
        return numBytesCopied
    }
    
    let writeFunc: curl_write_callback = { (buffer, size, num, p) -> Int in
        let received = Unmanaged<CurlReceivedData>.fromOpaque(p!).takeUnretainedValue()
        let bytes = UnsafeRawPointer(buffer!)
        let length = size * num
        let data = Data(bytes: bytes, count: length)
        received.data = data
        return length
    }
    
    init(socketPath: String) {
        self.socketPath = socketPath
    }
    
    func run(_ originalReq: URLRequest) async -> Result<CurlReceivedData, CurlError> {
        let req = (originalReq as NSURLRequest).copy() as! URLRequest
        return await withCheckedContinuation { continuation in
            queue.async {
                curl_easy_setopt_long(curl, CURLOPT_VERBOSE, 1)
                curl_easy_setopt_string(curl, CURLOPT_UNIX_SOCKET_PATH, socketPath)
                
                // convert the request into CURL arguments
                curl_easy_setopt_string(curl, CURLOPT_URL, req.url?.absoluteString)
                
                // set post
                if req.httpMethod == "POST" {
                    curl_easy_setopt_long(curl, CURLOPT_POST, 1)
                }
                
                // handle request body
                if let body = req.httpBody {
                    curl_easy_setopt_func_read(curl, CURLOPT_READFUNCTION, readFunc)
                    let bodyWrapper = CurlBodyData(body)
                    let bodyWrapperPointer = Unmanaged.passRetained(bodyWrapper).toOpaque()
                    curl_easy_setopt_pointer(curl, CURLOPT_READDATA, bodyWrapperPointer)
                    curl_easy_setopt_long(curl, CURLOPT_POSTFIELDSIZE, bodyWrapper.data.count)
                }
                
                // handle headers
                var slist: UnsafeMutablePointer<curl_slist>? = nil
                if let reqHeaders = req.allHTTPHeaderFields {
                    for (key, value) in reqHeaders {
                        slist = curl_slist_append(slist, "\(key): \(value)")
                    }
                }
                curl_easy_setopt_slist(curl, CURLOPT_HTTPHEADER, slist)
                
                // setup write function
                let received = CurlReceivedData()
                let pointer = Unmanaged.passUnretained(received).toOpaque()
                curl_easy_setopt_func_write(curl, CURLOPT_WRITEFUNCTION, writeFunc)
                curl_easy_setopt_pointer(curl, CURLOPT_WRITEDATA, pointer)
                
                let res = curl_easy_perform(curl)
                if res == CURLE_OK {
                    var code: Int64 = 0
                    curl_easy_getinfo_long(curl, CURLINFO_RESPONSE_CODE, &code)
                    continuation.resume(returning: Result.success(received))
                } else {
                    continuation.resume(returning: Result.failure(CurlError.unknown))
                }
                
                // cleanup
                curl_slist_free_all(slist)
                curl_easy_reset(curl)
            }
        }
    }
}
