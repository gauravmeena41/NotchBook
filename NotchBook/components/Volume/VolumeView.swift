//
//  VolumeView.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 12/10/24.
//

import SwiftUI

struct VolumeView: View {

  let currentVolume: Int32

  var body: some View {
    HStack {
      HStack {
        Image(
          systemName: currentVolume >= 80
            ? "speaker.wave.3"
            : currentVolume >= 40
              ? "speaker.wave.2" : currentVolume > 0 ? "speaker.wave.1" : "speaker.slash"
        )
        .foregroundColor(.white)
        .frame(width: 16, height: 16)

        Text("Volume (\(currentVolume)%)")
          .font(.subheadline)
          .foregroundColor(.white)
      }

      Spacer()

      GeometryReader { geometry in
        HStack {
          Rectangle()
            .fill(Color.gray)
            .frame(height: 6)
            .frame(width: CGFloat(Float32(currentVolume) / 100.0) * geometry.size.width)
            .cornerRadius(3)

          Spacer()
        }
      }
      .frame(height: 6)
      .frame(width: 120)
    }
    .frame(width: NotchSizes().sizeWithNotification.closed.width! - 30)
    .padding(.bottom)
  }
}
