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
the extensions - needs a build and `deploy.bat`.

## Building and publishing

The build runs in a [SlicerWeb](https://github.com/lassoan/SlicerWeb) checkout next to a checkout
of this repository. Settings of this computer go in `local.env` (not committed; see
`local.env.example`): `SW_DIST`, the folder the build is copied to (default:
`~/SlicerWeb-build/dist-slicerweb-app`, so that it does not replace the build of SlicerWeb itself).

On Windows, from this folder (needs Docker, Python, Node.js and the GitHub CLI signed in with
`gh auth login`):

| | |
|---|---|
| `build.bat` | builds everything: SlicerWeb as its checkout is (update it first), and the extensions. Each part is redone only if it changed: minutes, or hours when VTK, ITK or Slicer moved |
| `build.bat extensions` | builds only the extensions; `build.bat SlicerIGT` only the ones named (in `extensions.json` or `extensions/`) |
| `serve-local.bat [port]` | serves the build at http://localhost:4176/ to try it; Ctrl+C, then Y, stops it |
| `stop-local.bat [port]` | stops a local server, also one that has no window to press Ctrl+C in |
| `deploy.bat [channel]` | publishes the build - nothing is built here - to the channel: `latest` by default (branch `deploy/<channel>`) |

The build records when it was built and from which commits of SlicerWeb and of this repository
(`wheels/build-info.json`); the application shows it at the end of its menu (top right). The site is
built from the same SlicerWeb commit as the build, so that commit has to be pushed before
`deploy.bat`.

The same, on any system, in the SlicerWeb checkout:

```sh
python build.py --deployment ../slicerweb-app all
python scripts/publish_runtime.py --deployment ../slicerweb-app --channel latest --publish
```
