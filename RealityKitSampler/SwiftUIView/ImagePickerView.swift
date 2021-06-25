//
//  SwiftUIView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/24.
//

import SwiftUI

public struct ImagePickerView: UIViewControllerRepresentable {

    private let sourceType: UIImagePickerController.SourceType
    private let mediaType: String
    private let onImagePicked: (UIImage?,URL) -> Void
    @Environment(\.presentationMode) private var presentationMode

    public init(sourceType: UIImagePickerController.SourceType, mediaType: String, onImagePicked: @escaping (UIImage?,URL) -> Void) {
        self.sourceType = sourceType
        self.mediaType = mediaType
        self.onImagePicked = onImagePicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.mediaTypes = [self.mediaType]
        print(mediaType)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            mediaType: self.mediaType,
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let mediaType: String
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage?, URL) -> Void

        init(mediaType:String, onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage?,URL) -> Void) {
            self.mediaType = mediaType
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            switch mediaType {
            case "public.movie":
                if let url = info[.mediaURL] as? URL {
                    self.onImagePicked(nil, url)
                }
            default:
                if let image = info[.originalImage] as? UIImage,let url = info[.imageURL] as? URL {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    var newImage = UIImage()
                    switch image.imageOrientation.rawValue {
                    case 1:
                        newImage = imageRotatedByDegrees(oldImage: image, deg: 180)
                    case 3:
                        newImage = imageRotatedByDegrees(oldImage: image, deg: 90)
                    default:
                        newImage = image
                    }
                    if let data = newImage.pngData() {
                        let filePath = documentsDirectory.appendingPathComponent("temp.png")
                        try? data.write(to: filePath)
                        self.onImagePicked(image, filePath)
                    } else {
                        self.onImagePicked(image, url)
                    }
                }
            }
            self.onDismiss()
        }
        
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
        
        
        func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
            //Calculate the size of the rotated view's containing box for our drawing space
            if degrees == 90 {
                let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.height, height: oldImage.size.width))
                let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
                rotatedViewBox.transform = t
                let rotatedSize: CGSize = rotatedViewBox.frame.size
                //Create the bitmap context
                UIGraphicsBeginImageContext(rotatedSize)
                let bitmap: CGContext = UIGraphicsGetCurrentContext()!
                //Move the origin to the middle of the image so we will rotate and scale around the center.
                bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
                //Rotate the image context
                bitmap.rotate(by: (degrees * CGFloat.pi / 180))
                //Now, draw the rotated/scaled image into the context
                bitmap.scaleBy(x: 1.0, y: -1.0)
                bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.height / 2, y: -oldImage.size.width / 2, width: oldImage.size.height, height: oldImage.size.width))
                let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                return newImage
            } else {
                let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
                let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
                rotatedViewBox.transform = t
                let rotatedSize: CGSize = rotatedViewBox.frame.size
                //Create the bitmap context
                UIGraphicsBeginImageContext(rotatedSize)
                let bitmap: CGContext = UIGraphicsGetCurrentContext()!
                //Move the origin to the middle of the image so we will rotate and scale around the center.
                bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
                //Rotate the image context
                bitmap.rotate(by: (degrees * CGFloat.pi / 180))
                //Now, draw the rotated/scaled image into the context
                bitmap.scaleBy(x: 1.0, y: -1.0)
                bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
                let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                return newImage
            }
        }
    }
}
