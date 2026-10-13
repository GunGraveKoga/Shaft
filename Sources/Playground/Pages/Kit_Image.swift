import Foundation
import Shaft
import ShaftLucide

final class Kit_Image: StatefulWidget {
    func createState() -> some State<Kit_Image> {
        Kit_ImageState()
    }
}

final class Kit_ImageState: State<Kit_Image> {
    override func build(context: BuildContext) -> Widget {

        return PageContent {
            Text("Image")
                .textStyle(.playgroundTitle)

            Text("A widget that displays an image.")
                .textStyle(.playgroundAbstract)

            HorizontalDivider()

            // MARK: - Overview

            Text("Overview")
                .textStyle(.playgroundHeading)

            Text(
                """
                To display an image, use the `Image` widget. The image can be loaded \
                from a URL or from a local file.
                """
            )
            .textStyle(.playgroundBody)

            CodeSection(
                """
                Image.network(url: URL(string: "https://picsum.photos/300")!, width: 300, height: 300)
                """
            )

            Image.network(
                url: URL(string: "https://picsum.photos/300")!, 
                width: 300, 
                height: 300,
                errorBuilder: { context, error in
                    SizedBox(width: 300, height: 300) {
                        Column {
                            LucideIcon("image-off", size: 48, color: .init(0xFF_D3D3D3))
                            Text("Error: \(error)")
                        }
                    }
                }
            )
        }
    }
}
