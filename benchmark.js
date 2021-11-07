/*
Run make run on all sub folders, measure time and order by time spent
*/
const util = require('util');
const exec = util.promisify(require('child_process').exec);

const make = 'make';
const make_run = 'make run';
const make_clean = 'make clean';

const projects = ['c', 
    'clisp', 
//    'clojureapp', 
    'cpp', 
    'csharp',
    'd', 
//    'elixir', 
    'go', 
    'haskell', 
//    'io', 
//    'janet', 
    'java', 
    'javascript',
    'lua', 
    'nim', 
//    'python', 
    'rust', 
//    'typescriptapp'
    'zig'
];

async function execShell(cmd) {
    const { stdout, stderr } = await exec(cmd)
    if (stderr) {
        throw stderr
    }
    return stdout
}

async function run() {
    const working_dir = process.cwd()
    console.log('Running make run on all sub projects')
    for (const p of projects) {
        try {
            process.chdir(p)
            console.log(`Running make at project ${p}`)
            console.log(await execShell(make_clean))
            console.log(await execShell(make))
            process.chdir(working_dir)
        } catch (error) {
            console.log(`Error at project ${p}`)
            console.error(error)
            process.chdir(working_dir)
        } 
    }
    console.log('Benchmarking ...')
    const results = []
    for (const p of projects) {
        try {
            process.chdir(p)
            console.log(`Running benchmark of project ${p}`)
            const t0 = process.hrtime()
            await execShell(make_run)
            const [ sec, nanosec ] = process.hrtime(t0)
            const elapsed_time_ms = (sec * 1e9 + nanosec) / 1000000
            results.push({ project: p, elapsed_time_ms: elapsed_time_ms.toFixed(3) })
            process.chdir(working_dir)
        } catch (error) {
            console.log(`Error at project ${p}`)
            console.error(error)
            process.chdir(working_dir)
        } 
    }
    results.sort((a, b) => a.elapsed_time_ms - b.elapsed_time_ms)
    console.table(results)
}

run();
