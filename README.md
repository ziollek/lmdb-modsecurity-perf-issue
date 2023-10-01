# lmdb-modsecurity-perf-issue
The aim of this repo is to show how performance issue of reading LMBD from modsecurity  was revealed.



# feed lmdb on both environments with some collections:

```
for i in {1..10000}; do curl -H"x-set-sample: ${i}" -o /dev/null -s localhost:8081; done
for i in {1..10000}; do curl -H"x-set-sample: ${i}" -o /dev/null -s localhost:8082; done
```

# simple performance test based on ab tool

requests without argument (no lookups to LMDB) - requests are proxied to backend that responds in 200ms 
```
ab -k -c 8 -n 1000 -l "http://localhost:8081/users/200/random"
ab -k -c 8 -n 1000 -l "http://localhost:8082/users/200/random"
```

requests without blocked argument (block on first SecRule)

```
ab -k -c 8 -n 1000 "http://localhost:8081/?arg=1"
ab -k -c 8 -n 1000 "http://localhost:8082/?arg=1"
```

requests without blocked argument that is not blocked (1000 lookups per request)

```
ab -k -c 20 -n 500 -l "http://localhost:8081/users/200/random?arg=unknown"
ab -k -c 20 -n 500 -l "http://localhost:8082/users/200/random?arg=unknown"
```

TODO:
- adding gdb / lsof
- privileged mode
- gather instrumentation data: https://github.com/SpiderLabs/ModSecurity-nginx/pull/278#issuecomment-1098075814
- gather logs
- grafana