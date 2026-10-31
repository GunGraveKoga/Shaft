/// A widget that displays text that can be selected by the user.
///
/// This is essentially a read-only [TextField] with no decoration, allowing
/// users to select and copy text but not edit it.
///
/// Example usage:
/// ```swift
/// SelectableText("Hello, world!")
///
/// SelectableText(
///     "Styled selectable text",
///     style: TextStyle(fontSize: 20, fontWeight: .bold)
/// )
/// ```
public final class SelectableText: StatefulWidget {

    public init(
        _ data: String,
        key: (any Key)? = nil,
        style: TextStyle? = nil,
        strutStyle: StrutStyle? = nil,
        textAlign: TextAlign = .start,
        textDirection: TextDirection? = nil,
        maxLines: Int? = nil,
        focusNode: FocusNode? = nil,
        selectionColor: Color? = nil,
        dragStartBehavior: DragStartBehavior = .start,
        scrollPhysics: ScrollPhysics? = nil,
        textHeightBehavior: TextHeightBehavior? = nil,
        textWidthBasis: TextWidthBasis = .parent,
        onSelectionChanged: SelectionChangedCallback? = nil
    ) {
        self.data = data
        self.key = key
        self.style = style
        self.strutStyle = strutStyle
        self.textAlign = textAlign
        self.textDirection = textDirection
        self.maxLines = maxLines
        self.focusNode = focusNode
        self.selectionColor = selectionColor
        self.dragStartBehavior = dragStartBehavior
        self.scrollPhysics = scrollPhysics
        self.textHeightBehavior = textHeightBehavior
        self.textWidthBasis = textWidthBasis
        self.onSelectionChanged = onSelectionChanged
    }
    
    public let key: (any Key)?
    
    /// The text to display.
    public let data: String
    
    /// The style to use for the text.
    ///
    /// If null, defaults to the closest enclosing [DefaultTextStyle].
    public let style: TextStyle?
    
    public let strutStyle: StrutStyle?
    
    /// How the text should be aligned horizontally.
    public let textAlign: TextAlign
    
    /// The directionality of the text.
    public let textDirection: TextDirection?
    
    /// An optional maximum number of lines for the text to span, wrapping if
    /// necessary. If the text exceeds the given number of lines, it will be
    /// truncated according to the text overflow behavior.
    ///
    /// If this is null (the default), the text may span any number of lines.
    public let maxLines: Int?
    
    /// Controls whether this widget has keyboard focus.
    public let focusNode: FocusNode?
    
    /// The color to use when painting the selection.
    public let selectionColor: Color?
    
    /// Determines the way that drag start behavior is handled.
    public let dragStartBehavior: DragStartBehavior
    
    public let scrollPhysics: ScrollPhysics?
    
    public let textHeightBehavior: TextHeightBehavior?
    
    public let textWidthBasis: TextWidthBasis
    
    /// Called when the user changes the selection.
    public let onSelectionChanged: SelectionChangedCallback?
    
    public func createState() -> some State<SelectableText> {
        SelectableTextState()
    }
}

public final class SelectableTextState: State<SelectableText>,
    TextSelectionGestureDetectorBuilder.Delegate
{
    public var editableTextKey = StateGlobalKey<EditableTextState>()

    public var forcePressEnabled: Bool { false }

    public var selectionEnabled: Bool { true }

    private lazy var controller = TextEditingController()
    private lazy var localFocusNode = FocusNode()

    private var effectiveFocusNode: FocusNode {
        widget.focusNode ?? localFocusNode
    }

    public override func initState() {
        super.initState()
        controller.text = widget.data
    }

    public override func didUpdateWidget(_ oldWidget: SelectableText) {
        super.didUpdateWidget(oldWidget)
        if widget.data != oldWidget.data {
            controller.text = widget.data
        }
    }

    public override func dispose() {
        localFocusNode.dispose()
        controller.dispose()
        super.dispose()
    }

    private func handleSelectionChanged(
        selection: TextSelection?,
        cause: SelectionChangedCause?
    ) {
        widget.onSelectionChanged?(selection, cause)
    }

    public override func build(context: BuildContext) -> Widget {
        let gestureBuilder = TextSelectionGestureDetectorBuilder(delegate: self)

        let defaultTextStyle = DefaultTextStyle.of(context)
        var effectiveTextStyle = widget.style
        if effectiveTextStyle == nil || effectiveTextStyle!.inherit {
            effectiveTextStyle = defaultTextStyle.style.merge(widget.style)
        }

        let selectionColor: Color =
            widget.selectionColor ?? .argb(100, 0, 122, 255)
        let cursorColor: Color = .argb(0, 0, 0, 0)  // transparent - no cursor
        let backgroundCursorColor: Color = .argb(0, 0, 0, 0)

        let editable: Widget = EditableText(
            key: editableTextKey,
            autofocus: false,
            backgroundCursorColor: backgroundCursorColor,
            controller: controller,
            cursorColor: cursorColor,
            cursorWidth: 0,
            dragStartBehavior: widget.dragStartBehavior,
            enableInteractiveSelection: true,
            expands: false,
            focusNode: effectiveFocusNode,
            maxLines: widget.maxLines,
            mouseCursor: .system(.text),
            onSelectionChanged: handleSelectionChanged,
            readOnly: true,
            rendererIgnoresPointer: true,
            scrollPhysics: widget.scrollPhysics,
            selectionColor: selectionColor,
            showCursor: false,
            showSelectionHandles: false,
            strutStyle: widget.strutStyle,
            style: effectiveTextStyle ?? TextStyle(),
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            textHeightBehavior: widget.textHeightBehavior,
            textWidthBasis: widget.textWidthBasis
        )

        return gestureBuilder.buildGestureDetector(behavior: .translucent) {
            editable
        }
    }
}
