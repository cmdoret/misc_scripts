# Read and write text files by chunks using parallel processes and threads.
# Toy example to teach myself some concepts. In practice, unless the function
# chosen is very CPU intensive, the whole thing will be I/O bound.
# cmdoret, 20190208

# Example usage: FastReadWrite(path="test_mat.tsv", func=sum_csv, n_cpu=8, chunk_size=2048**2)

from os.path import getsize
import multiprocessing as mp
from threading import Thread
import shutil
import uuid
from copy import deepcopy


class FastReadWrite:
    """Handles parallelisation of file processing + I/O."""

    def __init__(
        self, path, func, n_cpu=2, chunk_size=1024 * 1024, header=False, *args, **kwargs
    ):
        """
        The file at `path` will be read and processed at `n_cpu` different
        equally spaced splits. Each processes will be fed lines in chunks of
        `chunk_size` bytes read from its split.
        Parameters
        ----------
        path : str
            Path to the file that will be read.
        n_cpu : int
            Number of parallel processes to use.
        chunk_size : int
            Chunk size in bytes.
        func :  function
            The function to be applied on each row
        """
        self.path = path
        self.size = getsize(path)
        self.n_cpu = n_cpu
        self.func = func
        self.args = args
        self.kwargs = kwargs
        self.chunk_size = chunk_size
        # Addresses where each process will start reading
        self.splits = [i * self.size // self.n_cpu for i in range(self.n_cpu)]
        # Adjust each process' start to end of line
        for index, split in enumerate(self.splits):
            with open(self.path, "r") as infile:
                infile.seek(split)
                infile.readline()
                self.splits[index] = infile.tell()

        if not header:
            self.splits[0] = 0
        self.splits.append(self.size)
        # Generate tmp output files with random names for each split
        self.split_files = [uuid.uuid4().hex + str(i) for i in range(self.n_cpu)]
        # Shared structure for holding current chunk content of all processes
        self.chunk_content = {cpu: None for cpu in range(self.n_cpu)}
        self.chunk_start = deepcopy(self.chunk_content)
        pool = mp.Pool(n_cpu)
        pool.map(self.spawn_consumer, range(self.n_cpu))

    def spawn_consumer(self, cpu_id):
        """Set up a process to read a split by chunks."""
        print(self.splits)
        self.chunk_start[cpu_id], end = self.splits[cpu_id : cpu_id + 2]
        n_chunk = 0
        self.read_chunk(cpu_id)
        while self.chunk_start[cpu_id] < end:
            print("START IS : ", self.chunk_start[cpu_id])
            present_chunk = self.chunk_content[cpu_id]
            # Read next chunk while processing current chunk in separate threads
            io_thread = Thread(target=self.read_chunk, args=(cpu_id,))
            cpu_thread = Thread(target=self.consume_chunk, args=(present_chunk,))
            io_thread.start()
            cpu_thread.start()
            io_thread.join()
            cpu_thread.join()
            n_chunk += 1
            print("CPU {0} has processed {1} chunks".format(cpu_id, n_chunk))

    def read_chunk(self, cpu_id):
        with open(self.path, "r") as sf:
            sf.seek(self.chunk_start[cpu_id])
            self.chunk_content[cpu_id] = sf.read(self.chunk_size)
            self.chunk_content[cpu_id] += sf.readline()
            self.chunk_start[cpu_id] = sf.tell()

    def consume_chunk(self, chunk):
        """Wrap potential operation to perform on lines of a chunk."""
        out = []
        done = False
        for line in chunk.splitlines():
            if not done:
                print("FIRST LINE IS : ", line)
                done = True
            out.append(self.func(line, *self.args, **self.kwargs))
        print("LAST LINE IS : ", line)
        return out

    def write_chunk(chunk_out, split_file):
        """Write the processed chunk into the corresponding split file."""
        with open(split_file, "w") as sf:
            sf.writelines(chunk_out)

    def merge_splits(self, merged_out):
        """Merge output files from each process into the correct order."""
        with open(merged_out, "wb") as out:
            for split_file in self.split_files:
                shutil.copyfileobj(open(split_file, "rb"), out)
