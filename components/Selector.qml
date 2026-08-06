pragma ComponentBehavior: Bound
import QtQuick
import "."

ListView {
    id: root
    required property ConfigAdapter config
    required property ColorsAdapter colors
    property int selectedIndex: 0
    property real tileWidth: width / config.number_of_pictures - 10
    property real shearOffset: config.height * Math.abs(config.x_factor)
    property bool initialPosition: true
    property real speed: 5000

    signal selected(path: string, i: int)
    orientation: ListView.Horizontal
    spacing: 4
    clip: true
    cacheBuffer: width * 2
    leftMargin: config.x_factor < 0 ? shearOffset : 0

    onCountChanged: {
        initialPosition = true;

        const step = tileWidth + spacing;
        const itemStart = selectedIndex * step;
        contentX = itemStart - width / 2 + tileWidth / 2;
        Qt.callLater(() => {
            initialPosition = false;
        });
    }

    function clampIndex(i) {
        return Math.max(0, Math.min(i, count - 1));
    }

    function clampX(x) {
        const max = contentWidth - width;
        const clamped = Math.max(0, Math.min(x, max));

        return config.x_factor < 0 ? clamped === 0 ? -shearOffset : clamped : clamped === 0 ? 0 : clamped === max ? x + shearOffset : clamped;
    }

    function ensureVisibleAnimated(i) {
        const step = tileWidth + spacing;
        const itemStart = i * step;
        const itemEnd = itemStart + tileWidth + 20;
        if (itemStart < contentX)
            contentX = clampX(itemStart);
        else if (itemEnd > contentX + width)
            contentX = clampX(itemStart - (width - step));
    }

    Behavior on contentX {
        enabled: !root.initialPosition

        SmoothedAnimation {
            id: anim
            property int v: 10
            duration: 500
        }
    }

    onSelectedIndexChanged: {
        ensureVisibleAnimated(selectedIndex);
    }

    delegate: SelectorItem {
        colors: root.colors
        width: root.tileWidth
        height: root.config.height
        configs: root.config
        selectedIndex: root.selectedIndex
        onClicked: i => {
            root.selectedIndex = i;
            root.selected(root.model.get(selectedIndex).filePath, selectedIndex);
        }
    }

    MouseArea {
        propagateComposedEvents: true
        anchors.fill: root
        onWheel: function (wheel) {
            root.contentX = root.clampX(root.contentX - wheel.angleDelta.y * 2);
            wheel.accepted = false;
        }
    }

    Keys.onPressed: function (event) {
        let step = 1;
        const big = config.number_of_pictures;
        switch (event.key) {
        case Qt.Key_J:
        case Qt.Key_L:
        case Qt.Key_Down:
        case Qt.Key_Right:
            moveCursor(speed, selectedIndex + step);
            break;
        case Qt.Key_K:
        case Qt.Key_H:
        case Qt.Key_Up:
        case Qt.Key_Left:
            moveCursor(speed, selectedIndex - step);
            break;
        case Qt.Key_Backtab:
            moveCursor(speed, (selectedIndex + step) % count);
            break;
        case Qt.Key_D:
            moveCursor(speed * big, selectedIndex + big);
            break;
        case Qt.Key_U:
            moveCursor(speed * big, selectedIndex - big);
            break;
        case Qt.Key_Space:
        case Qt.Key_Return:
            selected(root.model.get(selectedIndex).filePath, selectedIndex);
            break;
        case Qt.Key_Escape:
            Qt.quit();
            break;
        default:
            return;
        }
        event.accepted = true;
    }

    function moveCursor(speed, newIndex) {
        anim.v = speed;
        selectedIndex = clampIndex(newIndex);
    }
}
