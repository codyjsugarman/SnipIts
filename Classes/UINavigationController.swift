extension UINavigationController {

    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return visibleViewController!.supportedInterfaceOrientations()
    }
    public override func shouldAutorotate() -> Bool {
        if (visibleViewController != nil) {
            return visibleViewController!.shouldAutorotate()
        }
        return false
    }
}