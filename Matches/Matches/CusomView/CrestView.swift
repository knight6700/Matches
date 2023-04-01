
import SwiftUI
import NukeUI

struct CrestView: View {
    struct ViewState {
        var image: URL?
        var width: CGFloat
        var height: CGFloat
    }
    var viewState: ViewState
    var body: some View {
        LazyImage(url: viewState.image) { image in
            if let _ = image.error {
                Image(systemName: Images.placeHolder.rawValue)
                    .resizable()
                    .frame(width: viewState.width, height:viewState.height)
                    .cornerRadius(8)
                    .clipped()
                    .foregroundColor(.green)
                
            }else {
                image.image?
                    .resizable()
                    .frame(width: viewState.width, height:viewState.height)
                    .cornerRadius(8)
                    .clipped()
                
            }
        }
    }
}

#if DEBUG
struct PosterView_Previews: PreviewProvider {
    static var previews: some View {
        CrestView(viewState: .init(width: 30, height: 30))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
