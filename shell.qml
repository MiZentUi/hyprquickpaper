pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland

import "components"

PanelWindow {
    id: main
    implicitHeight: config_file.adapter.height
    implicitWidth: Screen.width
    color: "transparent"
    property int speed: 5000

    aboveWindows: true
    exclusionMode: "Ignore"
    exclusiveZone: 1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    Component.onCompleted: {
        Quickshell.execDetached(["bash", Quickshell.shellPath("cache.sh"), Quickshell.shellDir]);
    }

    function resolveEnvVars(inputPath) {
        return inputPath.replace(/\$(\w+)/g, function (match, varName) {
            return Quickshell.env(varName) ?? "";
        });
    }

    FileView {
        id: config_file
        path: Quickshell.shellPath("config.json")
        watchChanges: true
        onFileChanged: reload()

        onAdapterUpdated: {
            img_finder.running = true;
        }
        onLoaded: {
            img_finder.running = true;
        }
        ConfigAdapter {}
    }

    PathFinder {
        id: img_finder
        target_model: selector.model
        path: main.resolveEnvVars(config_file.adapter.wallpaper_path)
        cache_path: main.resolveEnvVars(config_file.adapter.cache_path)
    }

    FileView {
        id: colors_file
        path: Quickshell.shellPath("colors.json")
        watchChanges: true
        onFileChanged: reload()
        ColorsAdapter {}
    }

    Persistence {
        id: current_walpaper
        path: main.resolveEnvVars(config_file.adapter.cache_path) + '/.current'
    }

    Selector {
        id: selector
        anchors.fill: parent
        focus: true
        model: ListModel {}
        config: config_file.adapter
        colors: colors_file.adapter
        selectedIndex: Number(current_walpaper.load())
        onSelected: (path, i) => {
            current_walpaper.save(`${i}`);
            Quickshell.execDetached(["bash", Quickshell.shellPath("commands.sh"), path.replace(/ /g, "\\ ")]);
            Qt.quit();
        }
    }
}
