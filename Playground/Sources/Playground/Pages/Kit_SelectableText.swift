import Shaft

final class Kit_SelectableText: StatelessWidget {
    func build(context: BuildContext) -> Widget {
        PageContent {
            Text("SelectableText")
                .textStyle(.playgroundTitle)

            Text("A widget that displays text the user can select and copy, but not edit.")
                .textStyle(.playgroundAbstract)

            HorizontalDivider()

            Text("Basic Usage")
                .textStyle(.playgroundHeading)

            Text(
                """
                Use SelectableText to display read-only text that users can \
                select with click-and-drag. Useful for displaying content \
                users might want to copy.
                """
            )
            .textStyle(.playgroundBody)

            CodeSection(
                """
                SelectableText("This text can be selected!")
                """
            )

            SelectableText("This text can be selected! Try clicking and dragging to highlight it.")

            Text("Styled Text")
                .textStyle(.playgroundHeading)

            Text(
                """
                SelectableText accepts a style parameter, just like Text. \
                It also inherits from DefaultTextStyle.
                """
            )
            .textStyle(.playgroundBody)

            CodeSection(
                """
                SelectableText(
                    "Large bold selectable text",
                    style: TextStyle(
                        color: .argb(255, 0, 100, 200),
                        fontSize: 24,
                        fontWeight: .bold
                    )
                )
                """
            )

            SelectableText(
                "Large bold selectable text",
                style: TextStyle(
                    color: .argb(255, 0, 100, 200),
                    fontSize: 24,
                    fontWeight: .bold
                )
            )

            Text("Multiline")
                .textStyle(.playgroundHeading)

            Text(
                """
                By default, SelectableText supports multiple lines. \
                Set maxLines to limit the number of visible lines.
                """
            )
            .textStyle(.playgroundBody)

            CodeSection(
                """
                SelectableText(
                    \"\"\"
                    Line 1: Swift is a powerful language.
                    Line 2: Shaft brings cross-platform UI.
                    Line 3: SelectableText lets users copy content.
                    \"\"\",
                    maxLines: nil
                )
                """
            )

            SelectableText(
                """
                Line 1: Swift is a powerful and intuitive programming language.
                Line 2: Shaft brings cross-platform UI to Swift developers.
                Line 3: SelectableText lets users select and copy read-only content.
                Line 4: This is great for displaying code snippets, logs, or any text users might want to copy.
                """,
                maxLines: nil
            )

            Text("Custom Selection Color")
                .textStyle(.playgroundHeading)

            CodeSection(
                """
                SelectableText(
                    "Select me to see a green highlight!",
                    selectionColor: .argb(100, 0, 200, 100)
                )
                """
            )

            SelectableText(
                "Select me to see a green highlight!",
                selectionColor: .argb(100, 0, 200, 100)
            )

            Text("vs Text")
                .textStyle(.playgroundHeading)

            Text(
                """
                For comparison, regular Text cannot be selected. \
                Try selecting the text below — it won't work.
                """
            )
            .textStyle(.playgroundBody)

            Text("This is regular Text — you cannot select it.")
                .textStyle(.init(color: .argb(255, 150, 150, 150), fontSize: 17))
        }
    }
}
