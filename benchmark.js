/*
Run make run on all sub folders, measure time and order by time spent
*/
const util = require('util');
const exec = util.promisify(require('child_process').exec);
const os = require('os');

const cpuCount = os.cpus().length
const make = 'make'
const make_run = 'make run'
const make_clean = 'make clean'

const projects = ['c',
    'clisp',
    // 'clojureapp',
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
    'python',
    'rust',
//    'typescriptapp'
    'zig'
];

async function execShell(cmd, cwd) {
    const { stdout, stderr } = await exec(cmd, { cwd })
    if (stderr) {
        throw stderr
    }
    return stdout
}

const working_dir = process.cwd()

async function runMake(project) {
    try {
        const cwd = `${working_dir}/${project}`
        console.log(`Running make at project ${project}`)
        console.log(await execShell(make_clean, cwd))
        console.log(await execShell(make, cwd))
    } catch (error) {
        console.log(`Error at project ${project}`)
        console.error(error)
    }
}

async function solve(project) {
    try {
        const cwd = `${working_dir}/${project}`
        console.log(`Running benchmark of project ${project}`)
        const t0 = process.hrtime()
        await execShell(make_run, cwd)
        const [ sec, nanosec ] = process.hrtime(t0)
        const elapsed_time_ms = (sec * 1e9 + nanosec) / 1000000
        console.log(`Solve finished for project ${project}: ${elapsed_time_ms.toFixed(3)} ms`)
        return { project: project, elapsed_time_ms: elapsed_time_ms.toFixed(3) }
    } catch (error) {
        console.log(`Error at project ${project}`)
        console.error(error)
    }
}

function splitArray(array, chunkSize) {
    let i,j, temporary
    const result = []
    for (i = 0,j = array.length; i < j; i += chunkSize) {
        temporary = array.slice(i, i + chunkSize);
        result.push(temporary)
    }
    return result
}

async function run() {
    console.log('Running make run on all sub projects')
    await Promise.all(projects.map(project => runMake(project)))
    console.log('Benchmarking ...')
    // const results = await Promise.all(projects.map(project => solve(project)))
    let results = []
    for (let group of splitArray(projects, cpuCount)) {
        const groupResults = await Promise.all(group.map(project => solve(project)))
        results = results.concat(groupResults)
    }
    results.sort((a, b) => a.elapsed_time_ms - b.elapsed_time_ms)
    console.table(results)
}

run();
