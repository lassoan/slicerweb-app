let e=null,t=null;function n(e,t=[]){self.postMessage(e,t)}async function r(t){let{loadPyodide:r}=await import(
/* @vite-ignore */
t.pyodideURL+`pyodide.mjs`);e=await r({indexURL:t.pyodideURL,packageBaseUrl:t.pyodidePackagesURL,stdout:e=>n({type:`log`,level:`INFO`,message:e}),stderr:e=>n({type:`log`,level:`ERROR`,message:e}),env:{HOME:`/home/pyodide`,SLICERWEB:`1`,SLICERWEB_JOB:`1`}}),e.runPython(`
import os, sysconfig
_sp = sysconfig.get_paths()["purelib"]
_dirs = [f"{_sp}/vtk_libs", f"{_sp}/slicerweb_itk", f"{_sp}/slicer_home/lib/Slicer-${t.slicerVersion}",
         f"{_sp}/slicer_home/lib/Slicer-${t.slicerVersion}/qt-loadable-modules"]
os.environ["LD_LIBRARY_PATH"] = ":".join(_dirs + [os.environ.get("LD_LIBRARY_PATH", "")])
`),await e.loadPackage(t.pyodidePackages,{messageCallback:()=>{}});let i=e.pyimport(`micropip`);for(let e of t.wheels)n({type:`progress`,message:`Loading ${e.split(`/`).pop()}`,fraction:.5}),await i.install(e,{keep_going:!0});e.registerJsModule(`slicerweb_job`,{progress:(e,t)=>n({type:`progress`,message:e,fraction:t}),log:(e,t)=>n({type:`log`,level:e,message:t})}),e.runPython(`
import sys, sysconfig
_sp = sysconfig.get_paths()["purelib"]
for _dir in (f"{_sp}/slicer_home/lib/Slicer-${t.slicerVersion}",
             f"{_sp}/slicer_home/lib/Slicer-${t.slicerVersion}/qt-loadable-modules",
             f"{_sp}/slicer_home/lib/Slicer-${t.slicerVersion}/qt-scripted-modules"):
    if _dir not in sys.path:
        sys.path.append(_dir)
`),e.FS.mkdirTree(`/work`),n({type:`ready`})}async function i(r){t&&await t;try{r.packages?.length&&(n({type:`progress`,id:r.id,message:`Loading ${r.packages.join(`, `)}`,fraction:0}),await e.loadPackage(r.packages,{messageCallback:()=>{}}));for(let[t,n]of Object.entries(r.files??{})){let r=t.slice(0,t.lastIndexOf(`/`));r&&e.FS.mkdirTree(r),e.FS.writeFile(t,n)}let t=e.toPy({...r.globals??{},result:null});await e.runPythonAsync(r.code,{globals:t});let i=t.get(`result`),a={};for(let t of r.outputs??[])try{a[t]=e.FS.readFile(t)}catch{}n({type:`done`,id:r.id,result:i?.toJs?i.toJs({dict_converter:Object.fromEntries}):i,files:a},Object.values(a).map(e=>e.buffer)),i?.destroy?.(),t.destroy()}catch(e){n({type:`failed`,id:r.id,error:String(e?.message??e)})}}self.onmessage=async e=>{let a=e.data;a.type===`start`?(t=r(a).catch(e=>{n({type:`failed`,error:String(e?.message??e)})}),await t):a.type===`run`?await i(a):a.type===`cancel`&&self.close()};