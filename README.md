# slicerweb-app

The published [SlicerWeb](https://github.com/lassoan/SlicerWeb) application:
<https://lassoan.github.io/slicerweb-app/>

This branch is the configuration of the build, a SlicerWeb *deployment*
([docs/extensions.md](https://github.com/lassoan/SlicerWeb/blob/main/docs/extensions.md)); the site
itself is on the branch `deploy/latest`, which GitHub Pages serves. That branch holds one build and
no history: each build replaces the last one.

- `extensions.json`: the extensions of SlicerWeb the application bundles, by name - SlicerWeb's
  `extensions/` describes them, so they follow SlicerWeb.
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
a [SlicerWeb](https://github.com/lassoan/SlicerWeb) checkout, given a settings file kept outside the
checkouts that says where everything is on the computer (SlicerWeb's `deployment.env.example`):

```
SW_SLICERWEB=C:/D/SlicerWeb
SW_DEPLOYMENT=C:/D/slicerweb-app
SW_DIST=D:/SlicerWeb-build/dist-slicerweb-app
SW_PORT=4176
```

`SW_DIST` is where everything built goes. Needs Docker, Python, Node.js and the GitHub CLI signed in
with `gh auth login` (`slicerweb.bat` instead of `python slicerweb.py` on Windows):

| | |
|---|---|
| `python slicerweb.py <settings> build` | builds everything: SlicerWeb as its checkout is (update it first), and the extensions. Each part is redone only if it changed: minutes, or hours when VTK, ITK or Slicer moved |
| `python slicerweb.py <settings> build extensions` | builds only the extensions; `build SlicerIGT SlicerRT` only the ones named (in `extensions.json` or `extensions/`) |
| `python slicerweb.py <settings> serve` | serves the build at http://localhost:4176/ (`SW_PORT`) to try it; Ctrl+C stops it |
| `python slicerweb.py <settings> stop` | stops that server, also one that has no window to press Ctrl+C in |
| `python slicerweb.py <settings> deploy [channel]` | publishes the build - nothing is built here - to the channel: `latest` by default (branch `deploy/<channel>`) |

The build records when it was built and from which commits of SlicerWeb and of this repository
(`wheels/build-info.json`); the application shows it at the end of its menu (top right). The site is
built from the same SlicerWeb commit as the build, so that commit has to be pushed before `deploy`.
