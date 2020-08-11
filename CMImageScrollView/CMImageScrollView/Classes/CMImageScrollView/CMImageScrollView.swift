//
//  CMImageScrollView.swift
//  CMCommunityModel
//
//  Created by macmini03 on 2019/12/31.
//

import UIKit

/// 圖片詳細View管理者
public class CMImageScrollView: NSObject{
    
    /// scrollView
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    /// 可縮放的圖片View
    private lazy var zoomImageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    /// 黑背景View
    private lazy var blackBackgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 顯示Toast的View
    private lazy var showToastView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 拖移觸碰的開始點(記錄用)
    private var panStartLocation = CGPoint()
    
    /// 圖片開始移動的中心點(記錄用)
    private var imageStartMovingCenter = CGPoint()
    
    /// 原來的ImageView
    private weak var originImageView: UIImageView?
    
    /// 畫面淡入
    public func zoomIn(imageView: UIImageView) {
        
        originImageView = imageView
        
        guard let rootViewController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController,
            let rootView = rootViewController.view,
            let originImageView = originImageView else{
                return
        }
        
        let topButtonWidth: CGFloat = 44.0
        let topButtonHeight: CGFloat = 44.0
        var safeAreaTop: CGFloat = 20.0
        var safeAreaBottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeAreaTop = rootViewController.view.safeAreaInsets.top
            safeAreaBottom = rootViewController.view.safeAreaInsets.bottom
        } else{
            safeAreaTop = rootViewController.view.layoutMargins.top
            safeAreaBottom = rootViewController.view.layoutMargins.bottom
        }
        
        // 設定背景View
        blackBackgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        blackBackgroundView.backgroundColor = UIColor.black
        blackBackgroundView.alpha = 0
        rootView.addSubview(blackBackgroundView)
        
        // 設定關閉按鈕(左上方)
        let closeBtn = UIButton()
        let closeImage = UIImage(named: "ic_close_image", in: CMBundle.bundle, compatibleWith: nil)
        closeBtn.tintColor = .white
        closeBtn.setImage(closeImage, for: .normal)
        closeBtn.frame = CGRect(x: 0, y: safeAreaTop, width: topButtonWidth, height: topButtonHeight)
        closeBtn.addTarget(self, action: #selector(clickCloseBtn(_:)), for: .touchUpInside)
        blackBackgroundView.addSubview(closeBtn)
        
        // 設定更多按鈕(右上方)
        let moreBtn = UIButton()
        let moreImage = UIImage(named: "ic_more", in: CMBundle.bundle, compatibleWith: nil)
        moreBtn.tintColor = .white
        moreBtn.setImage(moreImage, for: .normal)
        moreBtn.frame = CGRect(x: UIScreen.main.bounds.width - topButtonWidth, y: safeAreaTop, width: topButtonWidth, height: topButtonHeight)
        moreBtn.addTarget(self, action: #selector(clickMoreBtn(_:)), for: .touchUpInside)
        blackBackgroundView.addSubview(moreBtn)
        
        // 設定scrollView
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.bouncesZoom = true
        let scrollViewY = safeAreaTop + topButtonHeight
        scrollView.frame = CGRect(x: 0, y: scrollViewY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - scrollViewY - safeAreaBottom)
        scrollView.backgroundColor = .clear
        rootView.addSubview(scrollView)
        
        // 設定連點手勢
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        // 設定zoomImageView
        // 轉換座標(參考網站：http://greenchiu.github.io/blog/2014/09/01/memo-the-uiview-convertrect/)
        zoomImageView.frame = originImageView.superview?.convert(originImageView.frame, to: scrollView) ?? CGRect()
        zoomImageView.isUserInteractionEnabled = true
        zoomImageView.image = originImageView.image
        zoomImageView.contentMode = .scaleAspectFit
        zoomImageView.clipsToBounds = true
        scrollView.addSubview(zoomImageView)
        
        // 設定拖移手勢
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        pan.maximumNumberOfTouches = 1
        zoomImageView.addGestureRecognizer(pan)
        
        // 設定顯示Toast的View
        let showToastViewHeight: CGFloat = 100
        showToastView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - safeAreaBottom - showToastViewHeight, width: UIScreen.main.bounds.width, height: showToastViewHeight)
        showToastView.isUserInteractionEnabled = false
        showToastView.backgroundColor = .clear
        rootView.addSubview(showToastView)
        
        // 原圖隱藏
        originImageView.alpha = 0
        
        // 動畫開始
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.zoomImageView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
            self.blackBackgroundView.alpha = 1
        }, completion: nil)
    }
    
    /// 畫面淡出
    private func zoomOut() {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.zoomImageView.frame = self.originImageView?.superview?.convert(self.originImageView?.frame ?? CGRect(), to: self.scrollView) ?? CGRect()
            self.blackBackgroundView.alpha = 0
        }, completion: { (didComplete) -> Void in
            self.scrollView.removeFromSuperview()
            self.zoomImageView.removeFromSuperview()
            self.blackBackgroundView.removeFromSuperview()
            self.showToastView.removeFromSuperview()
            self.panStartLocation = CGPoint()
            self.imageStartMovingCenter = CGPoint()
            self.originImageView?.alpha = 1
            self.originImageView = nil
        })
    }
    
    /// 連點事件
    @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        //只要放大倍率大於為最小(x1.0)時，一律變回最小(x1.0)，反之則放大為最大(x3.0)
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    /// 拖移事件
    @objc private func handlePan(recognizer: UISwipeGestureRecognizer){
        
        switch recognizer.state {
            
        case .began:
            //開始：紀錄"拖移觸碰的開始點"、"圖片開始移動的中心點"
            panStartLocation = recognizer.location(in: scrollView)
            imageStartMovingCenter = zoomImageView.center
            
        case .changed:
            //拖曳中：計算"圖片該移動多少"、"背景透明度"(以畫面總高的一半基準，越遠越透明)
            let point = recognizer.location(in: scrollView)
            zoomImageView.center = CGPoint(x: imageStartMovingCenter.x + (point.x - panStartLocation.x),
                                           y: imageStartMovingCenter.y + (point.y - panStartLocation.y))
            
            let totalMoving = getPointDistance(startPoint: zoomImageView.center, endPoint: imageStartMovingCenter)
            blackBackgroundView.alpha = 1 - (totalMoving / (UIScreen.main.bounds.height / 2.0))
            
        case .ended:
            
            //結束：畫面淡出
            zoomOut()
            
        default:
            break
        }
    }
    
    /// 點擊返回按鈕
    @objc private func clickCloseBtn(_ button: UIButton) {
        zoomOut()
    }
    
    /// 點擊更多按鈕
    @objc private func clickMoreBtn(_ button: UIButton) {
        
        guard let rootViewController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController else {
            return
        }
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let savePhoto = NSLocalizedString("儲存相片", comment: "")
        let saveImageAction = UIAlertAction(title: savePhoto, style: .default){
            [weak self] _ in
            guard let self = self else { return }
            if let image = self.originImageView?.image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        
        let cancel = NSLocalizedString("取消", comment: "")
        let cancelAction = UIAlertAction(title: cancel, style: .cancel)
        optionMenu.addAction(saveImageAction)
        optionMenu.addAction(cancelAction)
        rootViewController.present(optionMenu, animated: true, completion: nil)
    }
    
    /// 儲存事件回傳
    @objc public func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let saveFailed = NSLocalizedString("儲存失敗", comment: "")
            showToastView.makeToast("\(saveFailed) - \(error.localizedDescription)")
        } else {
            let imageSaved = NSLocalizedString("已儲存", comment: "")
            showToastView.makeToast(imageSaved)
        }
    }
    
    /// 取得兩點距離
    ///
    /// - Parameters:
    ///   - point: 起始點
    ///   - point: 終點
    /// - Returns: 距離
    private func getPointDistance(startPoint: CGPoint, endPoint: CGPoint) -> CGFloat {
        return sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2))
    }
}

// MARK: - ScrollViewDelegate
extension CMImageScrollView: UIScrollViewDelegate{
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomImageView
    }
}

