                Proxy   Nginx
        wrk     3900    5500
        hey     3800    4400

## wrk

    ➜  socketry-proxy git:(master) ✗ wrk -d10 -t2 -c25 http://127.0.0.1:9000
    Running 10s test @ http://127.0.0.1:9000
      2 threads and 25 connections
      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency     7.52ms    7.91ms  68.71ms   93.05%
        Req/Sec     1.96k   339.46     2.81k    67.50%
      39067 requests in 10.01s, 31.67MB read
    Requests/sec:   3900.93
    Transfer/sec:      3.16MB

    ➜  socketry-proxy git:(master) ✗ wrk -d10 -t2 -c25 http://127.0.0.1:8000
    Running 10s test @ http://127.0.0.1:8000
      2 threads and 25 connections
      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency    46.19ms  162.11ms 998.86ms   93.25%
        Req/Sec     3.05k   525.78     3.87k    85.87%
      55900 requests in 10.03s, 45.31MB read
    Requests/sec:   5572.28
    Transfer/sec:      4.52MB


## hey

    ➜  socketry-proxy git:(master) ✗ hey -z 10s -n 10000000 -c 25 http://127.0.0.1:9000

    Summary:
      Total:	10.0146 secs
      Slowest:	0.0691 secs
      Fastest:	0.0008 secs
      Average:	0.0064 secs
      Requests/sec:	3876.1497

      Total data:	23756616 bytes
      Size/request:	612 bytes

    Response time histogram:
      0.001 [1]	|
      0.008 [29729]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
      0.014 [8121]	|■■■■■■■■■■■
      0.021 [506]	|■
      0.028 [81]	|
      0.035 [19]	|
      0.042 [20]	|
      0.049 [106]	|
      0.055 [159]	|
      0.062 [67]	|
      0.069 [9]	|


    Latency distribution:
      10% in 0.0031 secs
      25% in 0.0040 secs
      50% in 0.0054 secs
      75% in 0.0074 secs
      90% in 0.0100 secs
      95% in 0.0119 secs
      99% in 0.0273 secs

    Details (average, fastest, slowest):
      DNS+dialup:	0.0000 secs, 0.0008 secs, 0.0691 secs
      DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
      req write:	0.0000 secs, 0.0000 secs, 0.0007 secs
      resp wait:	0.0060 secs, 0.0008 secs, 0.0455 secs
      resp read:	0.0004 secs, 0.0000 secs, 0.0629 secs

    Status code distribution:
      [200]	38818 responses



    ➜  socketry-proxy git:(master) ✗ hey -z 10s -n 10000000 -c 25 http://127.0.0.1:8000

    Summary:
      Total:	10.7513 secs
      Slowest:	1.0077 secs
      Fastest:	0.0008 secs
      Average:	0.0057 secs
      Requests/sec:	4405.7009

      Total data:	28988604 bytes
      Size/request:	612 bytes

    Response time histogram:
      0.001 [1]	|
      0.101 [47316]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
      0.202 [0]	|
      0.303 [0]	|
      0.404 [0]	|
      0.504 [0]	|
      0.605 [0]	|
      0.706 [0]	|
      0.806 [0]	|
      0.907 [0]	|
      1.008 [50]	|


    Latency distribution:
      10% in 0.0026 secs
      25% in 0.0032 secs
      50% in 0.0040 secs
      75% in 0.0055 secs
      90% in 0.0074 secs
      95% in 0.0090 secs
      99% in 0.0137 secs

    Details (average, fastest, slowest):
      DNS+dialup:	0.0000 secs, 0.0008 secs, 1.0077 secs
      DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
      req write:	0.0000 secs, 0.0000 secs, 0.0005 secs
      resp wait:	0.0056 secs, 0.0007 secs, 1.0076 secs
      resp read:	0.0001 secs, 0.0000 secs, 0.0094 secs

    Status code distribution:
      [200]	47367 responses
