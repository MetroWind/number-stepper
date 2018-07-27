import Cocoa

@IBDesignable
class NumberStepper: NSControl
{
    private var LabelView: NSTextField? = NSTextField(labelWithString: "Label")
    private var Text: NSTextField = NSTextField(string: "0")
    private var Stepper: NSStepper = NSStepper()
    private var Formatter: NumberFormatter = NumberFormatter()

    private var TextLeftAnchor: NSLayoutConstraint? = nil
    private var TextWidthConstraint: NSLayoutConstraint? = nil
    private var LabelRightAnchor: NSLayoutConstraint? = nil
    private var LabelHeightConstraint: NSLayoutConstraint? = nil
    private var LabelBaselineConstraint: NSLayoutConstraint? = nil

    @IBInspectable var Min: Double
    {
        get
        {
            return Stepper.minValue
        }
        set(value)
        {
            Stepper.minValue = value
            Formatter.minimum = NSNumber(value: value)
        }
    }

    @IBInspectable var Max: Double
    {
        get
        {
            return Stepper.maxValue
        }
        set(value)
        {
            Stepper.maxValue = value
            Formatter.maximum = NSNumber(value: value)
        }
    }

    @IBInspectable var Step: Double
    {
        get
        {
            return Stepper.increment
        }
        set(value)
        {
            Stepper.increment = value
        }
    }

    @IBInspectable var Value: Double
    {
        get
        {
            return Text.doubleValue
        }
        set(value)
        {
            Stepper.doubleValue = value
            Text.doubleValue = value
        }
    }

    /// The width of the number control (the box that shows the number). This is only effective when `Label` is empty.
    @IBInspectable var TextWidth: CGFloat
    {
        get
        {
            if TextWidthConstraint == nil
            {
                return 0.0
            }
            else
            {
                return TextWidthConstraint!.constant
            }
        }

        set(value)
        {
            TextWidthConstraint?.constant = value
        }
    }

    /// The label to display beside the number.
    @IBInspectable var Label: String
    {
        get
        {
            if LabelView == nil
            {
                return ""
            }
            else
            {
                return LabelView!.stringValue
            }
        }

        set(value)
        {
            if LabelView == nil
            {
                if value != ""
                {
                    LabelView = NSTextField(labelWithString: value)
                    initLabel()
                    setConditionalConstraints(withLabel: true)
                }
            }
            else if value == ""
            {
                LabelView?.removeFromSuperview()
                LabelView = nil
                setConditionalConstraints(withLabel: false)
            }
            else
            {
                LabelView?.stringValue = value
            }
        }
    }

// Cannot set Label to empty in interface builder. So this toggle is needed.
    @IBInspectable var HasLabel: Bool
    {
        get
        {
            return LabelView != nil
        }
        set(value)
        {
            if value
            {
                if LabelView == nil
                {
                    Label = "Label"
                }
            }
            else
            {
                if LabelView != nil
                {
                    Label = ""
                }
            }
        }
    }

    private func setConditionalConstraints(withLabel: Bool)
    {
        if withLabel
        {
            TextLeftAnchor?.isActive = false
            TextWidthConstraint?.isActive = true
            LabelRightAnchor?.isActive = true
            LabelHeightConstraint?.isActive = true
            LabelBaselineConstraint?.isActive = true
        }
        else
        {
            TextWidthConstraint?.isActive = false
            LabelRightAnchor?.isActive = false
            LabelHeightConstraint?.isActive = false
            LabelBaselineConstraint?.isActive = false
            TextLeftAnchor?.isActive = true
        }
    }

    private func initLabel()
    {
        LabelView!.alignment = .right
        LabelView!.font = NSFont.systemFont(ofSize: 0.0)
        addSubview(LabelView!)
        LabelView!.translatesAutoresizingMaskIntoConstraints = false

        LabelRightAnchor = LabelView?.rightAnchor.constraint(equalTo: Text.leftAnchor, constant: -8)
        LabelHeightConstraint = NSLayoutConstraint(item: LabelView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: LabelView!.font!.capHeight * 2.0)
        LabelBaselineConstraint = NSLayoutConstraint(item: LabelView!, attribute: .firstBaseline, relatedBy: .equal, toItem: Text, attribute: .firstBaseline, multiplier: 1.0, constant: 0.0)
    }

    private func initSubControls()
    {
#if TARGET_INTERFACE_BUILDER
        wantsLayer = true
        canDrawSubviewsIntoLayer = true
#endif

        Formatter.numberStyle = .decimal
        Formatter.usesGroupingSeparator = false
        Text.formatter = Formatter

        Min = 0
        Max = 100
        Step = 1
        Value = 0

        addSubview(Text)
        addSubview(Stepper)

        TextLeftAnchor = Text.leftAnchor.constraint(equalTo: self.leftAnchor)
        TextWidthConstraint = NSLayoutConstraint(item: Text, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64)

        Stepper.target = self
        Stepper.action = #selector(self.onStepperClick)
        Text.target = self
        Text.action = #selector(self.onTextConfirm)

        // Constraints
        Stepper.translatesAutoresizingMaskIntoConstraints = false
        Text.translatesAutoresizingMaskIntoConstraints = false
        Stepper.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        Stepper.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        Text.rightAnchor.constraint(equalTo: Stepper.leftAnchor, constant: -2).isActive = true
        Text.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        if(LabelView != nil)
        {
            initLabel()
        }

        setConditionalConstraints(withLabel: LabelView != nil)
    }

//    override func prepareForInterfaceBuilder()
//    {
//        super.prepareForInterfaceBuilder()
//        initSubControls()
//    }

    @objc private func onStepperClick(_ sender: NSStepper?)
    {
        Text.stringValue = Stepper.stringValue
        sendAction(action, to: target)
    }

    @objc private func onTextConfirm(_ sender: NSTextField?)
    {
        Stepper.stringValue = Text.stringValue
        sendAction(action, to: target)
    }

    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        initSubControls()
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        initSubControls()
    }

    override func draw(_ dirtyRect: NSRect)
    {
//#if TARGET_INTERFACE_BUILDER
//        // Label?.draw(Label?.frame)
//        Text.draw(Text.frame)
//        Stepper.draw(Stepper.frame)
//#endif
        super.draw(dirtyRect)


//        _Text.draw(_Text.frame)
//        _Stepper.draw(_Stepper.frame)
        // Drawing code here.
    }

}
