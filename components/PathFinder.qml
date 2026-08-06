import Quickshell.Io // for Process
import QtQuick

Process {
    id: root
    required property ListModel target_model
    required property string path

    running: false
    command: ["find", path, "-type", "f", "-printf", "%P\n"]
    stdout: StdioCollector {
        onStreamFinished: {
            const paths = this.text.split('\n').filter(el => el != '');
            paths.forEach(el => {
                root.target_model.append({
                    fileName: el,
                    filePath: root.path + '/' + el
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
