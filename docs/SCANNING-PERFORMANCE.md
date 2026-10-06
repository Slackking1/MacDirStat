# Scanner performance validation

The scanner uses `getattrlistbulk` to fetch names and regular-file metadata in
batches. Directories still use `fstatat` so mount/firmlink identity and directory
sizes match POSIX traversal. Unsupported filesystems retain a POSIX fallback on
a fresh directory descriptor. All enumeration stays inside the synchronous,
thread-scoped dataless-materialization opt-out.

## Reproduce

```sh
MACDIRSTAT_BENCHMARK_PATH=/path/to/stable/folder swift test -c release \
  --filter compareDirectoryEnumerationPerformance --no-parallel
```

The benchmark alternates POSIX, bulk, bulk, POSIX with four directory workers.
Each run builds the tree, computes aggregates and sorts it. It checks matching
file/folder counts, logical/allocated sizes, cloud-only files and incomplete
folders. File contents are not read. The ordinary suite separately compares
every entry's metadata, including sparse files, Unicode names and resource forks.
Live cloud and performance tests are opt-in; CI does not depend on cloud accounts
or hardware-specific timing thresholds.

## Measurements on 6 October 2026

| Tree | Files | Folders | POSIX runs | Bulk runs |
| --- | ---: | ---: | --- | --- |
| Local dependency tree | 13,286 | 1,534 | 5.626 s, 2.161 s | 1.161 s, 2.144 s |
| Live CloudStorage tree | 170,791 | 25,421 | 78.668 s, 56.245 s | 17.001 s, 17.086 s |
| Xcode Developer directory | 109,725 | 22,755 | 78.575 s, 33.925 s | 19.026 s, 11.925 s |

All four runs for each tree produced matching totals. The cloud tree measured
515,245,550,178 logical bytes and 46,763,343,872 allocated bytes, with 141,054
cloud-only files and 887 incomplete directories. A separate selected real
cloud-only directory retained its dataless flag and unchanged allocated blocks.

The later POSIX run was still about 3.3 times slower than the slower bulk run on
the cloud tree, and 2.8 times slower on the Xcode tree. The small dependency tree
showed substantial timing variation, including a nearly equal later pair. Cache
warmth, filesystem type and other machine activity affect results. These are
measurements of these trees, not a speed guarantee for every drive or whole-Mac
scan. Allocated totals are not unique physical storage or guaranteed reclaimable
space on APFS.

Apple references: [getattrlistbulk manual](https://github.com/apple/darwin-xnu/blob/main/bsd/man/man2/getattrlistbulk.2),
[dataless-file guidance](https://developer.apple.com/documentation/technotes/tn3150-getting-ready-for-data-less-files).
