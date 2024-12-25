# Chunk Offsets

```pre
--------------------    --------------------                                        -------------
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |   -n 4:
|                  |    |                  |
|   FILE.TXT       |    | FILE_00.TXT      |                                         -s size_in_bytes
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |    --------------------  ------------  
|                  |    |                  |    |                  |
|                  |    |                  |    |                  |
|                  |    |                  |    |                  |      -o OFFSET/OVERLAY FILE_00.TXT
|                  |    |                  |    |  FILE_01.EXT     |
|                  |    |                  |    |                  |
|                  |    --------------------    |                  |  -------------  -------------
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |    --------------------    |                  |  -------------
|                  |    |                  |    |                  |
|                  |    |                  |    |                  |
|                  |    |                  |    |                  |      -o OFFSET/OVERLAY FILE_01.TXT
|                  |    |   FILE_02.EXT    |    |                  |
|                  |    |                  |    --------------------  -------------  -------------
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |
|                  |    |                  |    --------------------  -------------
|                  |    |                  |    |                  |
|                  |    |                  |    |                  |
|                  |    |                  |    |  FILE_03.EXT     |      -o OFFSET/OVERLAY FILE_02.TXT
|                  |    |                  |    |                  |
|                  |    --------------------    |                  |  -------------  -------------
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |
|                  |                            |                  |  -------------  -------------
--------------------                            --------------------

INPUT FILE          |                                               |
                    |                 CHUNK FILES                   |
                    |                   -n 4                        |
```

If you specify -n 4, the script will split the file into 4 chunks.

If you specify -s 1000, the script will split the file into chunks of 1000 bytes.

If you specify -n 4 -o 100, the script will split the file into 4 chunks of 1000 bytes with an overlap of 100 bytes. The last 100 bytes of the first chunk will be the first 100 bytes of the second file. The last 100 bytes of the second chunk will be the first 100 bytes of the third file. The last 100 bytes of the third chunk will be the first 100 bytes of the fourth file until there is no more data left to chunk.

The same rule would apply to -s, but the size calculation needs to take that into account.

The -l option will use lines instead of bytes. offset will be in lines instead of bytes.o

For number of chunks, we take the file size and divide by the number of chunks. that will give us the chunk size.

If an offset is given the last offset number of bytes, the next file will contain the last offset number of bytes or lines, depending on the -l option. If a fixed byte length is specified by using the -s option, the size of each file will have to be adjusted to account for the additional offset bytes.

For n files, the chunk length will be (file_size + (offset * n)) / n

For s size will be length for the first chunk, the length - offset for all remaining chunks. this will ensure the same length for all chunk files except for the last one.

Lines should be handled in a similar fashion as size in bytes, only using line counts instead of byte counts.
