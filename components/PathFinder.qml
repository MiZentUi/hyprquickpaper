import Quickshell.Io // for Process
import QtQuick

Process {
    id: root
    required property ListModel target_model
    required property string path
    required property string cache_path

    running: false
    command: ["find", path, "-type", "f", "-printf", "%P\n"]
    stdout: StdioCollector {
        onStreamFinished: {
            const paths = this.text.split('\n').filter(el => el != '');
            const sortedPaths = paths.sort((a, b) => {
                const a_ = a.split(".")[0];
                const b_ = b.split(".")[0];
                return a_.localeCompare(b_, undefined, {
                    sensitivity: "base"
                });
            });
            sortedPaths.forEach(el => {
                root.target_model.append({
                    fileName: el,
                    filePath: root.path + '/' + el,
                    cashePath: root.cache_path + '/' + el
                });
            });
        }
    }
    stderr: StdioCollector {
        onStreamFinished: {
            if (text.length != 0) {
                console.error(`${root.toString()}: ${this.text}`);
            }
        }
    }
}
