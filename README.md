# lmdb-modsecurity-perf-issue
The aim of this repo is to show how performance issue of reading LMBD from modsecurity  was revealed.

# Building environment

The base build is significantly faster (should be at least two times) and allows reproducing problem, but it does not contain toolset to reveals root cause.

## What does the environment consist of?

The environment consists of three container:
- dangling-backend
- nginx-before-fix (exposed under localhost:8081)
- nginx-after-fix (exposed under localhost:8082)

As an upstream (dangling-backend) [long-api](https://datmt.com/backend/docker-image-to-simulate-long-delay-api-calls/) container is used that provide convenient way for controlling upstream delay via request url.


## Building base environment

```
docker-compose up -d --build
```

## Building profiling environment

Such environment requires to compile kernel which can take a significant time.
```
docker-compose -f docker-compose.yaml -f docker-compose.override.profiling.yaml up --build
```

Caveats: You have to bear in mind that profiling tools require compiled kernel headers in order to be available in a container.
Such headers have to be compatible with the host kernel (in the case of OSX is the kernel of `docker` VM). The above setup was tested only with `docker desktop` on `OSX` and with `docker` on `openSUSE Tumbleweed`.

## Building remarks

The consecutive runs does not require `--build` parameters.

# Preparing sample data

There exists the script that utilizes one of modsecurity rules to fill LMDB collections with sample data.

## Feeding LMBD on both environments with some collections

```
bash feed.sh 10000 8081
bash feed.sh 10000 8082
```

# How does the modssec configuration consists of?

The configuration is prepared in such a way to exaggerate the concurrent access to LMD.
It contains two main parts:
- first part allows adding rules to collection that is stored in LMDB
- second part makes a lot (fifty) lookups to mentioned collection in order to find a needle

# Testing performance

The nginx configuration has enabled verbose access log that allows verifying the all phases of processing request by nginx.
The logs can be previewed by the following commands:
nginx before fix:
```
docker-compose exec nginx-before-fix tail -f /var/log/nginx/access.log
```
nginx after fix:
```
docker-compose exec nginx-after-fix tail -f /var/log/nginx/access.log
```

The meaning of particular variables can be found [here](https://nginx.org/en/docs/varindex.html).

## Simple performance test based on ab tool

Requests without argument (no lookups to LMDB) - requests are proxied to backend that responds in 200ms
```
ab -k -c 20 -n 80 -l "http://localhost:8081/users/200/random"
ab -k -c 20 -n 80 -l "http://localhost:8082/users/200/random"
```

Requests with blocked argument (block on first SecRule)

```
ab -k -c 20 -n 80 "http://localhost:8081/?arg=1"
ab -k -c 20 -n 80 "http://localhost:8082/?arg=1"
```

Requests without blocked argument that is not blocked (1000 lookups per request)

```
ab -k -c 20 -n 80 -l "http://localhost:8081/users/200/random?arg=unknown"
ab -k -c 20 -n 80 -l "http://localhost:8082/users/200/random?arg=unknown"
```

# Profiling

If the containers are spawned from profiling file then they consist some toolset that allows to determine the bottlenecks in nginx processes.
Below there are sample commands that allows how to reveal problem

```
docker-compose exec nginx-before-fix bash
trace-bpfcc -t  'p:/usr/local/modsecurity/lib/libmodsecurity.so.3.0.6:msc_process_request_headers "start"' 'r:/usr/local/modsecurity/lib/libmodsecurity.so.3.0.6:msc_process_request_headers "stop"' 2>/dev/null
```

As a result of such profiling one line is printed when:
- the nginx process calls `msc_process_request_headers` function from modsecurity library
- the nginx process gets a response from `msc_process_request_headers` function

All such logs are additionally enriched with the pid of the nginx process and a timestamp with milliseconds resolution. It is worth mentioning that the logs can be printed in improper order.
The profiling is focused on purpose on `msc_process_request_headers` because the rules defined in a sample modsec policy are processed in request headers phase that is wrapped by `msc_process_request_headers`.

In order to compute the processing time for each request within a test, you can use the following snippet:

Terminal one
```
docker-compose exec nginx-before-fix bash
trace-bpfcc -t  'p:/usr/local/modsecurity/lib/libmodsecurity.so.3.0.6:msc_process_request_headers "start"' 'r:/usr/local/modsecurity/lib/libmodsecurity.so.3.0.6:msc_process_request_headers "stop"' 2>/dev/null > /tmp/profiling.log
```

In another terminal order the benchmark and wait for a results. After that stop profiling process (Ctrl+c) and compute results:

```
cat /tmp/benchmark.log  | sort -n | awk '{if ($6 == "start") { data[$2] = $1} else { calls++; summary += 1000 * ($1 - data[$2]); print $1, $2, 1000 * ($1 - data[$2]) }} END {print "Total time spent on locking:", summary, " number of calls: ", calls}'
```
