#!/usr/bin/python

# ----------------------------------------------------------------------------
#                 Copyright (c) 1996-2009 AT&T
#                      All Rights Reserved
#  THIS IS UNPUBLISHED PROPRIETARY SOURCE DOCUMENTATION OF AT&T
#        The copyright notice above does not evidence any
#         actual or intended publication of such source.
#
# change history:
#
#      02/01/2009  (Iker Arizmendi)      created
#
# ----------------------------------------------------------------------------

PROG_NAME = "whtest"
PROG_VERSION = "1.0"

# ============================================================================
# documentation
#
doc = '''
-----------------------------------------------------------------------------
OVERVIEW
-----------------------------------------------------------------------------
whtest will simulate one or more concurrent HTTP clients that issue
requests to a given URL. The tool supports HTTP GET and streaming
HTTP POST requests. In its simplest form, whtest can be used to issue an
HTTP GET as follows:

    $ whtest http://my/url

where the first argument is the URL one wishes to test. To stream a single
file to a server via POST the following is used instead:

    $ whtest http://my/url --mode=stream --input=myfile

By default whtest will stream the file at a rate of 400 bytes every 0.25
seconds (ie, AMR encoding mode 7); the --chunk-bytes and --chunk-interval options
can be used to change the rate as appropriate.

To simulate more than one concurrent client or to issue the same request
more than once whtest provides --num-threads, --min-req and --req-delay
options. Eg,

    $ whtest http://my/url --mode=stream   \\
                           --input=myfile  \\
                           --num-threads=5 \\
                           --min-req=10    \\
                           --req-delay=0.5

This example will simulate 5 clients (ie, threads) each of which will issue
the request 10 times with a random 0-0.5 second delay between each request.

-----------------------------------------------------------------------------
INPUT LISTS
-----------------------------------------------------------------------------
whtest can also accept an input list through the --list option.  Each line
entry in the list is interpreted as a pipe-delimited list of arguments.
Before a request is issued, any pattern '@0', '@1', '@2', ...  in the
URL is replaced with the URL-encoded corresponding argument.

If the mode is "stream", the first arg, and maybe only arg,
of each line is also interpreted as the path of a file to be streamed
via HTTP POST. Eg,

    $ whtest http://my/url --mode=stream --list=mylist

If the mode is "text", the first arg of each line is usually the value
of the text argument; the request will be an HTTP GET
and the url will look like

    $ whtest http://my/url?text=@0 --mode=text --list=mylist

A similar, but less general, scheme is used for the --reference option
(see below).

By default requests are issued in the order they appear in the file. To
alter the order whtest provides the --select option which can take one
of the following values:

     normal:  select items from the input list in order
    shuffle:  apply a random shuffle operation to the input list
      cycle:  each client cycles the list by one

these operations are applied to the input list for each simulated client.
Finally, whtest will try to honor the --min-req and --max-req options
when dealing with lists. If the input list has less than --min-req items,
whtest will pad the input list before applying the --select method. If
the list has more than --max-req items whtest truncates the list as
needed.

-----------------------------------------------------------------------------
REFERENCES
-----------------------------------------------------------------------------
The --reference option is used in two ways: it is used for simple regression
testing (see below) and it can be sent to the server in the url body.
If the url contains the pattern '@REF', that pattern is substituted by the
value of the current reference entry.
Eg,
    whtest --list=MYLIST --reference=MYREFS --mode=stream \\
           http://HOST:PORT/asr?lm=LM&coding=amr&reference=@REF

-----------------------------------------------------------------------------
STREAMING
-----------------------------------------------------------------------------
The options --chunk-bytes and --chunk-interval control the rate at which
a file is POST'ed to a server. By default these parameters are set to
values suitable for single rate, AMR-encoded audio files.

Note that one can simulate a standard, non-streaming POST by selecting a
large enough chunk size.

-----------------------------------------------------------------------------
SAVING HTTP RESPONSE BODIES
-----------------------------------------------------------------------------

The --resp-file option lets users specify a file name template to save the
content of all HTTP response bodies. If the template parameter contains the
special tokens @tid and @rid they will be replaced with the thread number
and request input number, respectively. Eg,

    whtest --resp-file=test.@tid.@rid.txt

Request inputs are numbered according to their position in the input list.

-----------------------------------------------------------------------------
OUTPUT
-----------------------------------------------------------------------------
When whtest completes it generates (on stdout) two cumulative histograms, one
for connection times and the second for response latencies. These capture the
total number of requests that fall below the given time. Eg, the following
output shows that all 5 connections (100%) were completed in 0.01 seconds,
that 2 requests (40%) had a response latency of 0.035 sec, and that all
requests had a response latency of less than or equal to 0.037 sec.

    HTTP Client Test
    DATE: 2009-03-08 15:11:55.543101
    URL: http://localhost:8080/nlu?text=@0

    Conn Time Histogram
    --------------------------------
       00.000 sec:    3 ( 60%)
       00.000 sec:    4 ( 80%)
       00.000 sec:    4 ( 80%)
       00.000 sec:    4 ( 80%)
       00.001 sec:    5 (100%)

    Latency Histogram
    --------------------------------
       00.030 sec:    1 ( 20%)
       00.031 sec:    1 ( 20%)
       00.033 sec:    1 ( 20%)
       00.035 sec:    2 ( 40%)
       00.037 sec:    5 (100%)

    --------------------------------
    Total Requests: 5

The connection time captures the time a simulated client takes to make a
TCP connection. The response latency measures how long it took the server
to send back a response. Response latencies are always measured from the
time the last byte of a request was sent (ie, for streaming requests the
timer is started when the last stream chunk is transmitted).

Additional histograms may be available depending on what server result
objects contain.  Among those that *may* be defined:

    cpuTime
    clockTime
    audioTime
    cpuVsAudio
    clockVsAudio
    clockMinusAudioTime
    privDirty
    sharedDirty
    majorPageFaults
    minorPageFaults
    chanIdleTime

There is also a --report option to print a full report, including the
HTTP request issued by the test, all replies received, and the final
report that was sent to stdout. Eg,

    $ whtest http://myurl --report=myreport.txt

Finally, there is a tracing option that provides more detail while the
test is running. Use the --trace-level option, or the -v  shorthand. Eg,

    $ whtest http://myurl --trace-level=debug
    $ whtest -vv http://myurl

-----------------------------------------------------------------------------
REGRESSION TESTING
-----------------------------------------------------------------------------
The --reference option provides a mechanism for whtest to check the responses
sent by the server and compare them to expected responses. In addition,
the --res-handler option lets users provide their own functions for parsing
the HTTP body and for comparing the parsed body to a corresponding reference.
Eg,

    $ whtest http://my/url?arg=@0 my_input_list.txt --mode=text \\
               --reference=myrefs.txt \\
               --res-handler=myhandler.py

where the file 'myhandler.py' is a Python file with two functions that
must have the following signatures:

    def parse(headers, body):
        metrics = {}
        return body, metrics

    def match(parsed_text, reference):
        return True

The 'parse' function takes a list of header-value tuples and a string with
the body of the HTTP response; it should return a new string with the parsed
result and a dictionary with any metrics information. The 'match' function
takes the parsed result and the corresponding reference item as argument and
should return True or False as appropriate. The default parse and match
handlers are meant to work with WATSON's JSON format for ASR requests.

'''

# ============================================================================
#
import sys
import os
import socket
import errno
import time
import random
import urllib
import re
import urlparse
import StringIO
import email
import copy
import datetime
import signal
import xml.dom.minidom as minidom
import threading
import logging
import traceback
import inspect

# ============================================================================
# common trace log
#
LOG = logging.getLogger('main')
LOG.addHandler(logging.StreamHandler(sys.stdout))

# ============================================================================
# command line option parsing
#
def buildOptionParser ():

    from optparse import OptionParser

    version = "%s: %s\n" % (PROG_NAME, PROG_VERSION)
    usage = "%s url inputlist" % PROG_NAME
    description = "%s is a utility to stress test a server over HTTP" % PROG_NAME

    oparser = OptionParser(usage=usage, description=description, version=version)

    oparser.add_option('--doc', action='store_true', dest='doc',
                       default=False,
                       help="print documentation")
    oparser.add_option('--input', action='store', type='string', dest='inputItem',
                       default=None,
                       help="input item [None]")
    oparser.add_option('--list', action='store', type='string', dest='inputList',
                       default=None,
                       help="list file with one input item per line [None]")
    oparser.add_option('--num-threads', action='store', type='int', dest='numThreads',
                       default=1,
                       help="number of concurrent clients (ie, threads) [1]")
    oparser.add_option('--header', action='append', type='string', dest='headers',
                       default=[],
                       help="additional HTTP headers")
    oparser.add_option('--mode', action='store', type='string', dest='mode',
                       default='text',
                       help="input mode; stream|text [stream]")
    oparser.add_option('--select', action='store', type='string', dest='select',
                       default='normal',
                       help="input selection method; normal|shuffle|cycle [normal]")
    oparser.add_option('--min-req', action='store', type='int', dest='minReq',
                       default=1,
                       help="minimum number of requests per thread")
    oparser.add_option('--max-req', action='store', type='int', dest='maxReq',
                       default=None,
                       help="maximum number of requests per thread")
    oparser.add_option('--reference', action='store', type='string', dest='refs',
                       default=None,
                       help="optional list of references for match caclulation")
    oparser.add_option('--res-handler', action='store', type='string', dest='resHandler',
                       default=None,
                       help="Python file with custom result evaluation functions")
    oparser.add_option('--report', action='store', type='string', dest='report',
                       default=None,
                       help="save test output and final report to this file [None]")
    oparser.add_option('--chunk-bytes', action='store', type='int', dest='bytesPerTx',
                       default=400,
                       help="bytes per chunk [400]")
    oparser.add_option('--chunk-interval', action='store', type='float', dest='txInterval',
                       default=0.250,
                       help="delay between chunks in sec [0.250].  A dekay of 0 is equivalent to sending all the audio at once.")
    oparser.add_option('--req-delay', action='store', type='float', dest='reqDelay',
                       default=0.5,
                       help="max random delay between requests [0.5 sec]")
    oparser.add_option('--timeout', action='store', type='float', dest='txTimeout',
                       default=None,
                       help="socket timeout [None]")
    oparser.add_option('--resp-file', action='store', type='string', dest='respFile',
                       default=None,
                       help="save response bodies using specified file name as a template [None]")
    oparser.add_option('--hist', action='append', dest='histograms',
                       default=[],
                       help="specify additional histograms to print to stdout")
    oparser.add_option('--hist-size', action='store', type='int', dest='histSize',
                       default=5,
                       help="number of histogram buckets [5]")
    oparser.add_option('--trace-level', action='store', type='string', dest='traceLevel',
                       default='warning',
                       help='write an execution trace to standard output. One of "error" , "warning", "info", "verbose", "detail" or "debug" [warning].  Ignored if "-v" option is used')
    oparser.add_option("--verbose", "-v",
                       action="count", dest="verbose", default=0,
                       help="Shorthand for --trace-level.  Repeating the option increases the trace level")

    return oparser

# ============================================================================
# initialize the trace logging object
#
def initialize_trace (level_str):
    try:
        levels = { 'debug'   : logging.DEBUG,
                   'detail'  : logging.DEBUG,
                   'verbose' : logging.INFO,
                   'info'    : logging.INFO,
                   'warning' : logging.WARNING,
                   'error'   : logging.ERROR }
        if level_str.lower() not in levels:
            raise RuntimeError, "invalid trace level [%s]" % level_str
        level = levels[level_str.lower()]
        l = logging.getLogger('main')
        f = logging.Formatter('%(asctime)s %(threadName)s %(message)s')
        l.handlers[0].setFormatter(f)
        l.setLevel(level)
    except Exception, e:
        if LOG.level == logging.DEBUG:
            e_type, e_value, e_tb = sys.exc_info()
            tb_str = ''.join(traceback.format_exception(e_type, e_value, e_tb))
            LOG.debug('ERROR: %s\n' % tb_str)
        sys.stderr.write('%s ERROR: %s\n' % (PROG_NAME, e))
        sys.exit(1)

# ============================================================================
# extract the item of interest from the result. By default assume we're
# getting JSON with a results[0].reco property, and possibly a metrics
# property; if it fails we just return the raw text.
#
def result_parse(headers, body):
    metrics = {}
    parse = body
    try:
        # incomming is JSON, convert it to Py strings
        conv = { "null": "None", "true": "True", "false": "False" }
        for d in conv:
            body = body.replace(d, conv[d]);        
        # convert str to Py object
        res = eval(body)
        # look for a 'metrics' sub-dictionary
        if 'metrics' in res and type(res['metrics']) is dict:
            metrics = res['metrics']
            for k in metrics.keys():
                # entries must be numerical scalars;
                # convert strings to numbers; dropping units, if any
                if type(metrics[k]) is str:
                    metrics[k] = float(metrics[k].split()[0])
        # for added convenience, define "clockMinusAudioTime":
        if "clockTime" in metrics and "audioTime" in metrics:
            metrics["clockMinusAudioTime"] = float(metrics["clockTime"]) - float(metrics["audioTime"])
        # one-best result
        parse = str(res["results"][0])
    except Exception, e:
        LOG.debug("result_parse eval(body) failed: %s" % e)
    return parse, metrics

# ============================================================================
# compare result to reference; return True if the reference
# text is anywhere in the returned text
#
def result_match(res_text, ref_text):
    match = False
    try:
        match = (res_text.find(ref_text) >= 0)
    except Exception, e:
        pass
    return match

# =============================================================================
# thrown when the server disconnects or the client hits a socket timeout
#
class IncompleteRequest(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return self.value

# ============================================================================
# on completion of each request we get one of these objects
#
class Result(object):
    __slots__ = ('bytesTx', 'connTime', 'txTime', 'resTime',
                 'raw', 'code', 'body', 'headers')
    def __init__ (self):
        self.bytesTx = 0
        self.connTime = 0.0
        self.txTime = 0.0
        self.resTime = 0.0
        self.raw = ''
        self.code = ''
        self.headers = []
        self.body = ''

# ============================================================================
# input to a request and its optional reference transcription
#
class Request(object):
    __slots__ = ('rid', 'rinput', 'reference', 'result', 'error')
    def __init__ (self, rid, i, r):
        self.rid = rid
        self.rinput = i
        self.reference = r
        self.result = Result()
        self.error = None

# ============================================================================
# tasks contain a list of requests plus some meta data common to
# all of the requests (chunk size, tx interval, target URL, etc).
#
class Task(object):
    __slots__ = ('tid', 'abort', 'mode', 'url', 'headers', 'requests',
                  'bytesPerTx', 'txInterval', 'reqDelay', 'respFile')
    def __init__ (self, tid, mode, url, headers, requests, bytesPerTx,
                        txInterval, reqDelay, respFile):
        assert (mode in ['text', 'stream'])
        self.tid = tid
        self.abort = 0
        self.mode = mode
        self.url = url
        self.headers = headers
        self.requests = requests
        self.bytesPerTx = bytesPerTx
        self.txInterval = txInterval
        self.reqDelay = reqDelay
        self.respFile = respFile

# ============================================================================
# parse a list of input items and, optionally, an accompanying list of
# reference transcriptions; checks that each file in the list exists;
# returns a list of Request objects; if there are less than min_req
# input items pad the list with items starting from the front.
#
def parse_input_list (mode, input_item, list_path, ref_path, min_req, max_req):
    assert (mode in ['text', 'stream'])
    if not input_item and not list_path:
        # special case; simple text queries can make do with just a URL
        if mode == 'text':
            return min_req * [Request(1, None, None)]
        raise RuntimeError, 'input item or input list is required'
    # input items can be file paths or input strings
    input_items = []
    if not list_path:
        assert(input_item)
        input_items.append(input_item)
    else:
        list_path = os.path.abspath(list_path)
        list_dir = os.path.dirname(list_path)
        if not os.path.isfile(list_path):
            raise RuntimeError, "no such list file [%s]" % list_path
        for p in open(list_path, 'r'):
            p = p.strip()
            if not p:
                continue
            if mode == 'stream':
                if not os.path.isabs(p):
                    p = os.path.join(list_dir, p)
            input_items.append(p)
    # in stream mode the input items are file paths
    if mode == 'stream':
        for p in input_items:
            if not os.path.isfile(p):
                raise RuntimeError, "stream file does not exist [%s]" % p
    # refs are optional
    references = [None] * len(input_items)
    if ref_path:
        references = []
        for r in open(ref_path, 'r'):
            r = r.strip()
            if not r:
                continue
            references.append(r)
    if len(input_items) != len(references):
        raise RuntimeError, "input and reference lengths differ"
    # requests numbered by position in the input list
    req_ids = range(1, len(input_items) + 1)
    # raw input list; cut down to size or pad as needed
    reqlist = [Request(n, i, j) for n, i, j in zip(req_ids, input_items, references)]
    if max_req:
        # cut
        reqlist = reqlist[:max_req]
    elif min_req:
        # pad
        n = 0
        while len(reqlist) < min_req:
            # need new objs, not refs to existing objs
            reqlist.append(copy.deepcopy(reqlist[n]))
            n += 1
    # done
    return reqlist

# ============================================================================
# generate a histogram from a list of numbers
#
def gen_histogram (items, num_buckets):
    assert(items and num_buckets >= 0)
    hist = {}
    if num_buckets == 0:
        return hist
    # we expect floats
    items = [float(i) for i in items]
    items.sort()
    min_i = items[0]
    max_i = items[-1]
    bucket_inc = (max_i - min_i) / num_buckets
    fmt = '%06.2f'
    if bucket_inc < 0.01:
        fmt = '%06.3f'
    for i in range(1, num_buckets + 1):
        bucket = min_i + bucket_inc * i
        if i == num_buckets:
            bucket = max_i
        hist[bucket] = 0
        for i in items:
            if i <= bucket:
                hist[bucket] += 1
    return hist

# ============================================================================
# wrappers for socket ops 
#
def sock_send (sock, data):
    try:
        sock.sendall(data)
    except socket.error, e:
        if e.args[0] in (errno.EPIPE, errno.ECONNRESET):
            raise IncompleteRequest("sock_send, server disconnect")
        raise e

def sock_recv (sock, n):
    b = None
    try:
        b = sock.recv(n)
    except socket.timeout:
        raise IncompleteRequest("sock_recv, socket timeout")
    except socket.error, e:
        if e[0] not in [errno.EPIPE, errno.ECONNRESET]:
            raise
    if not b:
        raise IncompleteRequest("sock_recv, server disconnect")
    return b

def sock_connect (host, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    rv = sock.connect_ex( (host, port) )
    if rv == 0:
        return sock
    if rv in (errno.EAGAIN, errno.EWOULDBLOCK):
        raise IncompleteRequest("connection attempt timed out")
    s = errno.errorcode[rv]
    raise RuntimeError, "connection to %s:%d failed [%s]" % (host, port, s)

# ============================================================================
# connect to server URL; returns tuple (socket, host, url_path, conn_t)
#
def url_connect (url):
    url_parts = urlparse.urlparse(url)
    if url_parts[0].lower() != 'http':
        raise RuntimeError, "only HTTP URLs are supported [%s]" % url
    host_port = url_parts[1].split(':')
    serverHost = host_port[0]
    serverPort = 80
    if len(host_port) > 1:
        serverPort = int(host_port[1])
    urlPath = url_parts[2] + '?' + url_parts[4]
    # connect to server
    connect_t = time.time()
    svrsock = sock_connect (serverHost, serverPort) 
    connect_t = time.time() - connect_t
    LOG.debug("connect time: %.3f sec, socket timeout [%s]" % (connect_t, svrsock.gettimeout()))
    return svrsock, serverHost, urlPath, connect_t

# ============================================================================
# read a single HTTP response; returns the response and the time it took for
# it to arrive in a tuple (resp, wait_t); we try to look for a content length
# header in the first chunk of a response and if we find it, we read only that
# many bytes; if no content length header is found we read to EOF.
#
def get_http_response (sock):
    resp = StringIO.StringIO()
    start_t = first_byte_t = time.time()
    nbytes = 0
    hdr_len = content_len = -1
    try:
        while True:
            b = sock_recv(sock, 2056)
            if nbytes == 0:
                first_byte_t = time.time() - start_t
            nbytes += len(b)
            resp.write(b)
            # check if we're done reading the response headers (the HTTP spec
            # requires a double \r\n sequence to terminate the headers).
            if hdr_len < 0:
                v = resp.getvalue()
                hdr_len = v.find('\r\n\r\n')
                try:
                    content_len = int(re.search('^Content-Length\s*:(.*)$', v, re.M|re.I).group(1))
                except:
                    pass
                LOG.debug("Content Length: %s" % content_len)
            # don't wait for EOF if we don't have to        
            if hdr_len >= 0 and content_len >= 0 and nbytes >= hdr_len + content_len:
                break
    except IncompleteRequest:
        LOG.warning("get_http_response interrupted after %d bytes (hdr len %d, content len %d)" % (
                     nbytes, hdr_len, content_len) )
    if nbytes > 0 and hdr_len < 0:
        LOG.warning("bad HTTP response, terminating double-CRLF is missing")
    if content_len < 0:
        LOG.warning("response had no content length")
    total_t = time.time() - start_t
    v = resp.getvalue()
    if not v:
        raise RuntimeError, "server disconnected, total_t %.3f sec" % total_t
    return v, first_byte_t, total_t

# ============================================================================
# parse an HTTP response and return the data and content type
# of the enclosed MIME message (if any)
#
def parse_http_response (r):
    assert(type(r) == str)
    r = r.split('\n', 1)
    if len (r) != 2:
        raise RuntimeError, "bad HTTP message: %s" % r
    status_line, mime_body = r
    status_line = status_line.split(None, 2)
    if len(status_line) != 3:
        raise RuntimeError, "bad HTTP status line: %s" % status_line
    httpver, httpcode, httpmsg = status_line
    m = email.message_from_string(mime_body)
    content_type = m.get_content_type().lower().strip()
    payload = m.get_payload()
    headers = m.items()
    return httpcode, headers, payload

# ============================================================================
# process a stream request; stream a file to server URL in chunks of
# bytesPerTx bytes with a delay between chunks of txInterval seconds
#
def do_stream_request (streamfile, url, headers, bytesPerTx, txInterval):
    LOG.info("stream request [url: %s]" % url)
    # allow txInterval = 0
    assert(streamfile and bytesPerTx > 0 and txInterval >= 0)
    rsize = os.stat(streamfile).st_size
    LOG.debug("stream: %s (%d bytes)" % (streamfile, rsize))
    # connect to server
    svrsock, host, url_path, conn_t = url_connect(url)
    # send HTTP request headers
    sock_send(svrsock, "POST %s HTTP/1.1\r\n" % url_path)
    sock_send(svrsock, "User-Agent: %s/%s\r\n" % (PROG_NAME, PROG_VERSION))
    sock_send(svrsock, "Host: %s\r\n" % host)
    sock_send(svrsock, "Transfer-Encoding: chunked\r\n")
    sock_send(svrsock, "Connection: close\r\n")
    # custom headers
    set_content_type = True
    for h in headers:
        h = h.strip()
        if re.match('^content-type\s*:.*$', h, re.M|re.I):
            set_content_type = False
        sock_send(svrsock, "%s\r\n" % h)
    # only set content type if it isn't already provided
    if set_content_type:
        sock_send(svrsock, "Content-Type: application/octet-stream\r\n")
    # no more headers
    sock_send(svrsock, "\r\n")
    # sleep can not be depended on for precise intervals as it puts us at the
    # mercy of the kernel scheduler - we try to do some corrections here but
    # this only helps somewhat
    auf = open(streamfile, 'rb')
    bytes_tx = 0
    start_t = time.time()
    try:
        while True:
            sleep = bytes_tx / bytesPerTx * txInterval - (time.time() - start_t)
            if sleep > 0:
                time.sleep(sleep)
            buf = auf.read(bytesPerTx)
            if not buf:
                break
            # chunked encoding: chunk length, data, empty line
            bytes_tx += len(buf)
            sock_send(svrsock, '%x\r\n' % len(buf))
            sock_send(svrsock, buf)
            sock_send(svrsock, '\r\n')
        # end of stream is marked by a zero length chunk
        sock_send(svrsock, '%x\r\n' % 0)
        sock_send(svrsock, '\r\n')
    except socket.error, e:
        # we don't want errors early in the stream to keep us
        # from getting the HTTP error response below
        if e[0] not in [errno.EPIPE, errno.ECONNRESET]:
            raise e
    LOG.debug("request issued (%d bytes)" % bytes_tx)
    # how long it took to stream
    stream_t = time.time() - start_t
    # sit and wait for the response
    resp, first_t, total_t = get_http_response(svrsock)
    LOG.debug("response, %d bytes, first_t %.3f sec, total_t %.3f sec" % (len(resp), first_t, total_t))
    # parse response
    httpcode, headers, body = parse_http_response(resp)
    # make sure the client machine isn't swamped and unable
    # to stream at the correct rate
    if txInterval > 0:
        expected_t = float(rsize) / bytesPerTx * txInterval
        if abs(stream_t - expected_t) > expected_t * 0.10:
            LOG.warning("stream rate is off (actual %.3f sec, expected_t %.3f sec)" % (
                         stream_t, expected_t))
    # finito
    r = Result()
    r.bytesTx = bytes_tx
    r.connTime = conn_t
    r.txTime = time.time() - start_t
    r.resTime = total_t
    r.raw = resp
    r.code = httpcode
    r.headers = headers
    r.body = body
    return r

# ============================================================================
# process a text GET request;
# the url has been processed for all @REF or @0, @1, ...subsitutions
#
def do_text_request (url, headers):
    # connect to server
    LOG.info("text request [url: %s]" % url)
    svrsock, host, url_path, conn_t = url_connect(url)
    # send HTTP request
    buf = "GET %s HTTP/1.1\r\n" % url_path
    sock_send(svrsock, buf)
    # basic headers
    sock_send(svrsock, "User-Agent: %s/%s\r\n" % (PROG_NAME, PROG_VERSION))
    sock_send(svrsock, "Host: %s\r\n" % host)
    sock_send(svrsock, "Connection: close\r\n")
    # custom headers
    for h in headers: 
        sock_send(svrsock, "%s\r\n" % h)
    sock_send(svrsock, "\r\n")
    # sit and wait for the response
    LOG.debug("request issued")
    resp, first_t, total_t = get_http_response(svrsock)
    LOG.debug("response, %d bytes, first_t %.3f sec, total_t %.3f sec" % (len(resp), first_t, total_t))
    # parse response
    httpcode, headers, body = parse_http_response(resp)
    # finito
    r = Result()
    r.bytesTx = len(buf)
    r.connTime = conn_t
    r.txTime = 0.0
    r.resTime = total_t
    r.raw = resp
    r.code = httpcode
    r.headers = headers
    r.body = body
    return r

# ============================================================================
# processes a list of requests
#
def process_task (task):
    for req in task.requests:
        if task.abort:
            LOG.debug('aborting task')
            break
        try:
            LOG.info('start request [input=%s]' % req.rinput)
            delay_sec = task.reqDelay * random.random()
            if delay_sec > 0:
                LOG.debug ("delay %.3f sec" % delay_sec)
                time.sleep(delay_sec)
            # insert list fields in url
            url = task.url
            rinput = req.rinput
            streamfile = rinput
            # substitute input args @0, @1, etc...
            if rinput is not None:
                rinputl = rinput.split('|')
                streamfile = rinputl[0]
                for i in range(len(rinputl)):
                    val = urllib.quote(rinputl[i])
                    pat = "@%d" % i
                    url = url.replace(pat, val)
            # insert reference in url
            if url.find('@REF') >= 0:
                ref = urllib.quote(req.reference)
                url = url.replace('@REF', ref)
            if task.mode in ['stream']:
                req.result = do_stream_request(streamfile, url, task.headers,
                                               task.bytesPerTx, task.txInterval)
            else:
                req.result = do_text_request(url, task.headers)
            res = req.result
            # dump each response body to file on demand; if per-request rinput
            # is available save that as well
            resp_body_file = None
            if task.respFile:
                resp_body_file = task.respFile.replace('@tid', str(task.tid))
                resp_body_file = resp_body_file.replace('@rid', str(req.rid))
                open(resp_body_file, 'wb').write(res.body)
            # log message - don't log the body if it's been saved to file
            msg = "HTTP reply: status code %s, conn_t %.3f sec | res_t %.3f sec | res_sz %d bytes" % (
                   res.code, res.connTime, res.resTime, len(res.raw))
            if resp_body_file:
                msg += " | res_file [%s]" % resp_body_file
            elif LOG.level == logging.DEBUG:
                msg += "\n%s\n" % res.raw
            LOG.info(msg)
        except IncompleteRequest, e:
            LOG.error("ERROR: %s" % e)
            req.error = '%s' % e
        except Exception, e:
            req.error = '%s' % e
            if LOG.level == logging.DEBUG:
                e_type, e_value, e_tb = sys.exc_info()
                tb_str = ''.join(traceback.format_exception(e_type, e_value, e_tb))
                LOG.debug('ERROR:\n%s' % tb_str)
            else:
                LOG.error("ERROR:\n%s\n" % e)
    LOG.debug("task complete")

# ============================================================================
# prints metrics info
#
def print_metrics (f, metrics, hist_size, complete, mismatches,
                   errors, http_errors, incomplete):

    for mk, mv in metrics.items():
        mv = [float(v) for v in mv]
        f.write ('\n')
        f.write ('--------------------------------\n')
        f.write ('%s\n' % mk)
        f.write ('\n')
        if len(mv) == 0:
             f.write (' Count: %d\n' % len(mv))
             continue
        h = gen_histogram(mv, hist_size)
        keys = h.keys()
        keys.sort()
        for k in keys:
            pct = '%d%%' % int(float(h[k])/complete*100)
            f.write ('   %06.3f: %4d (%s)\n' % (k, h[k], pct.rjust(4)))
        f.write ('\n')
        f.write (' Count: %d\n' % len(mv))
        f.write ('   Avg: %.3f\n' % (sum(mv)/len(mv)))
        f.write ('   Max: %.3f\n' % (max(mv)))
        f.write ('   Min: %.3f\n' % (min(mv)))
    f.write ('\n')
    f.write('--------------------------------\n')
    f.write('Summary:\n\n')
    f.write('    Complete: %d\n' % complete)
    f.write('    Incomplete: %d\n' % incomplete)
    f.write('    Mismatches: %d\n' % mismatches)
    f.write('    Errors: %d\n' % errors)
    f.write('    Non-200 HTTP: %d\n\n' % http_errors)

# ============================================================================
# Execution starts here
#
if __name__ == '__main__':

    oparser = buildOptionParser()
    (opts, args) = oparser.parse_args(sys.argv)

    if opts.doc:
        print doc
        sys.exit(0)

    try:
        if len(args) != 2:
            raise RuntimeError, "%s: bad argument count" % args[0]

        if opts.maxReq and opts.maxReq < opts.minReq:
            raise RuntimeError, "max-req cannot be less than min-req"

        mode = opts.mode.lower()
        if mode not in ['text', 'stream']:
            raise RuntimeError, "mode must be 'text' or 'stream'"

        if opts.inputItem and opts.inputList:
            raise RuntimeError, "--input and --list cannot be used together"

        if opts.respFile and opts.numThreads > 1:
            if '@tid' not in opts.respFile:
                raise RuntimeError, "--resp-file template must specify @tid when num-threads > 1"

        if opts.histSize < 0:
            raise RuntimeError, "--hist-size must be >= 0"

        url = args[1]

        traceLevel = opts.traceLevel
        traceLevels = ["warning", "info", "verbose", "detail", "debug" ]
        if traceLevel not in traceLevels:
            raise RuntimeError, "bad trace-level value [%s]" % traceLevel
        verbose = opts.verbose
        if verbose > 0:
            if verbose >= len(traceLevels):
                verbose = len(traceLevels) - 1
            traceLevel = traceLevels[verbose]
        initialize_trace(traceLevel)

        # do this first, in case we can't open the file for some reason
        report = open('/dev/null', 'w')
        if opts.report:
            report = open(opts.report, 'w')

        # creates a list of Request objects
        request_list = parse_input_list(mode, opts.inputItem, opts.inputList,
                                      opts.refs, opts.minReq, opts.maxReq)

        # define handlers responsible for parsing server responses for useful
        # info and checking if the response matches the reference; use our
        # handler functions by default, but allow user to override
        r_parse = result_parse
        r_match = result_match
        if opts.resHandler:
            global_ns = { 'LOG' : LOG }
            execfile(opts.resHandler, global_ns)
            f = global_ns.get('parse')
            if not f or not inspect.isfunction(f):
                raise RuntimeError, "handler file [%s] has no parse() func" % opts.resHandler
            r_parse = f
            f = global_ns.get('match')
            if not f or not inspect.isfunction(f):
                raise RuntimeError, "handler file [%s] has no match() func" % opts.resHandler
            r_match = f

        # set timeout henceforth for /all/ socket operations (in all threads)
        socket.setdefaulttimeout(opts.txTimeout)

        # start up the threads; assign to each one a copy of the input list
        # and apply an optional cycle or shuffle to each thread's copy.
        threads = []
        for i in range(opts.numThreads):
            requests = copy.deepcopy(request_list)
            if opts.select == 'random' :
                random.shuffle(requests)
            elif opts.select == 'cycle':
                requests = requests[i:] + requests[:i]
            task = Task(i + 1, opts.mode, url, opts.headers, requests, opts.bytesPerTx,
                        opts.txInterval, opts.reqDelay, opts.respFile)
            t = threading.Thread(target=process_task, args=[task])
            t.task = task
            t.setDaemon(True)
            t.start()
            threads.append(t)

        # wait for them to finish; note that we're relying on the fact that
        # CPython masks interrupts on all threads except the main thread and
        # that access to primitive types like Int is atomic
        while True:
            try:
                for t in threads:
                    if t.isAlive():
                        t.join(0.50)
                        break
                alive = 0
                for t in threads:
                    if t.isAlive():
                        alive += 1
                if alive == 0:
                    break
            except KeyboardInterrupt:
                LOG.info('Aborting, please wait...')
                for t in threads:
                    t.task.abort = 1

        # collect the results
        metrics = {}
        latencies = []
        conn_times = []
        mismatches = 0
        incomplete = 0
        errors = 0
        http_errors = 0
        for t in threads:
            for req in t.task.requests:
                report.write('\n' + 80 * '=' + '\n\n')
                report.write('INPUT: %s\n' % req.rinput)
                res = req.result
                report.write('LATENCY: conn_t %.3f sec | resp_t %.3f sec\n' % (res.connTime, res.resTime))
                if req.error:
                    errors += 1
                    report.write('ERROR: %s\n' % req.error)
                    continue
                if req.result.bytesTx == 0:
                    incomplete += 1
                    report.write('INCOMPLETE: True\n')
                    continue
                report.write('RESPONSE: \n%s\n\n' % req.result.raw)
                if req.result.code != '200':
                    http_errors += 1
                    continue
                # only include good '200' responses in the metrics
                latencies.append(res.resTime)
                conn_times.append(res.connTime)
                # extract items of interest from response
                parsed_body, m = r_parse(res.headers, res.body)
                # accumulate metrics
                for k, v in m.items():
                    metrics.setdefault(k, []).append(v)
                # did we get what we were looking for?
                if parsed_body != res.body:
                    report.write('\nPARSED BODY: \n%s\n' % parsed_body)
                if req.reference:
                    m = 'REFERENCE'
                    if not r_match(parsed_body, req.reference):
                        mismatches += 1
                        m += ' MISMATCH'
                    report.write('\n%s: \n%s\n' % (m, req.reference))

        # our own metrics have higher priority
        metrics['respLatency'] = latencies
        metrics['connTime'] = conn_times

        # opening output message
        report_hdr  = 'WATSON HTTP Client Test\n\n'
        report_hdr += '   date: %s\n' % datetime.datetime.now()
        report_hdr += '   url: %s\n' % url
        report_hdr += "   mode: %s\n" % opts.mode
        report_hdr += "   threads: %s\n" % opts.numThreads
        report_hdr += "   requests/thread: %d\n" % len(request_list)
        report_hdr += "   select method: %s\n" % opts.select
        report_hdr += "   req delay: %.3f sec\n" % opts.reqDelay
        report_hdr += "   bytes/chunk: %d\n" % opts.bytesPerTx
        report_hdr += "   chunk interval: %.3f sec\n" % opts.txInterval
        report_hdr += "   result handler: %s\n" % opts.resHandler
        report_hdr += "   input item: %s\n" % opts.inputItem
        report_hdr += "   input list: %s\n" % opts.inputList
        # total "good" responses
        complete = len(latencies)

        # print summary to report file
        report.write('\n')
        report.write(report_hdr)
        print_metrics(report, metrics, opts.histSize, complete, mismatches,
                      errors, http_errors, incomplete)

        # the print to stdout
        # select which histograms to print to stdout (response
        # latency is always printed)
        which = opts.histograms + ['respLatency']
        for k in metrics.keys():
            if k not in which:
                del metrics[k]
        sys.stdout.write('--------------------------------\n')
        sys.stdout.write(report_hdr)
        print_metrics(sys.stdout, metrics, opts.histSize, complete, mismatches,
                      errors, http_errors, incomplete)

    except KeyboardInterrupt:
        LOG.info('ctrl-C detected. Exiting...')
        os.kill(os.getpid(), signal.SIGKILL)

    except Exception, e:
        if LOG.level == logging.DEBUG:
            e_type, e_value, e_tb = sys.exc_info()
            tb_str = ''.join(traceback.format_exception(e_type, e_value, e_tb))
            LOG.debug('ERROR: %s\n' % tb_str)
        sys.stderr.write('%s ERROR: %s\n' % (PROG_NAME, e))
        sys.exit(1)

