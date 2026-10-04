# slicerweb-app

The published [SlicerWeb](https://github.com/lassoan/SlicerWeb) application:
<https://lassoan.github.io/slicerweb-app/>

This branch is the configuration of the build, a SlicerWeb *deployment*
([docs/extensions.md](https://github.com/lassoan/SlicerWeb/blob/main/docs/extensions.md)); the site
itself is on the branch `deploy/latest`, which GitHub Pages serves. That branch holds one build and
no history: each build replaces the last one.

- `application.json`: the configuration of the application:
  - `extensions.slicerweb`: the extensions of SlicerWeb it bundles, by name - SlicerWeb's
    `extensions/` describes them, so they follow SlicerWeb;
  - `extensions.folder`: the folder of description files of its own (`extensions`);
  - `features`: `developerMode` (`enabledByDefault`, `disabledByDefault`, or `unavailable`: off and
    not offered in the settings), `pythonConsole` and `extensionsManager` (`true` or `false`).

  A change of `features` needs no build: `deploy` takes it as it is.
- `extensions/*.json`: other extensions, as Slicer ExtensionsIndex description files (none yet). A
  file here named as one of SlicerWeb takes its place (to build it at another revision, say). The
  site is public: their sources must be public too.
- `.github/workflows/publish-app.yml`: publishes a channel - `latest`, or another such as `stable` -
  to the branch `deploy/<channel>`, from the release `runtime-<channel>`.

A change of the web application in SlicerWeb (a push to its `web/`) publishes `deploy/latest` again
by itself, with the runtime that `runtime-latest` has. A change of the runtime - VTK, ITK, Slicer,
the extensions - needs `build` and `deploy` (below).

## Building and publishing

This checkout holds the configuration only. It is built, published and tried with `slicerweb.py` of
a [SlicerWeb](https://github.com/lassoan/SlicerWeb) checkout, run in this checkout (or given it
with `-C <folder>`). Its env file,
`.env`, says where everything is on the computer (copied from SlicerWeb's `examples/minimal/.env.example`; `.gitignore`
keeps it out of the repository):

```
SW_SLICERWEB=C:/D/SlicerWeb
SW_DIST=D:/SlicerWeb-build/dist-slicerweb-app
SW_PORT=4176
```

`SW_DIST` is where everything built goes. Needs Docker, Python, Node.js and the GitHub CLI signed in
with `gh auth login`:

| | |
|---|---|
| `python C:/D/SlicerWeb/slicerweb.py build` | builds everything: SlicerWeb as its checkout is (update it first), and the extensions. Each part is redone only if it changed: minutes, or hours when VTK, ITK or Slicer moved |
| `python C:/D/SlicerWeb/slicerweb.py build extensions` | builds only the extensions; `build extensions SlicerIGT SlicerRT` only the ones named (in `application.json` or `extensions/`) |
| `python C:/D/SlicerWeb/slicerweb.py serve` | serves the build at http://localhost:4176/ (`SW_PORT`) to try it; Ctrl+C stops it |
| `python C:/D/SlicerWeb/slicerweb.py stop` | stops that server, also one that has no window to press Ctrl+C in |
| `python C:/D/SlicerWeb/slicerweb.py deploy [channel]` | publishes the build - nothing is built here - to the channel: `latest` by default (branch `deploy/<channel>`) |

The build records when it was built and from which commits of SlicerWeb and of this repository
(`wheels/build-info.json`); the application shows it at the end of its menu (top right). The site is
built from the same SlicerWeb commit as the build, so that commit has to be pushed before `deploy`.
