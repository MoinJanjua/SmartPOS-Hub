import UIKit

class OverviewViewController: UIViewController {

    @IBOutlet weak var MianView: UIView!
    @IBOutlet weak var detailMianView2: UIView!
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var todaySalesAmount: UILabel!
    @IBOutlet weak var totalSalesAmount: UILabel!
    
    @IBOutlet weak var AllButton: UIButton!
    @IBOutlet weak var SaleaButton: UIButton!
    @IBOutlet weak var RepairsButton: UIButton!
    @IBOutlet weak var viewdashb: UIView!
    @IBOutlet weak var Nodatalbl: UILabel!
    
    var order_Detail: [AllSales] = [] // Contains all orders
    var filteredOrders: [AllSales] = [] // Contains filtered orders
    
    var currency = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        //applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        //addDropShadow(to: detailMianView2)
        
        TableView.dataSource = self
        TableView.delegate = self
        updateNoDataLabelVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"

        if let savedData = UserDefaults.standard.array(forKey: "OrderDetails") as? [Data] {
            let decoder = JSONDecoder()
            order_Detail = savedData.compactMap { data in
                do {
                    let order = try decoder.decode(AllSales.self, from: data)
                    return order
                } catch {
                    print("Error decoding order: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        
        calculateSalesAmounts()
        showAllOrders() // Show all orders by default
    }
    
    @IBAction func showAllOrders() {
        filteredOrders = order_Detail // Show all orders
        TableView.reloadData()
        updateNoDataLabelVisibility()
    }
    
    @IBAction func showSalesOrders() {
        filteredOrders = order_Detail.filter { $0.SaleType == "Earnings" } // Filter for sales
        TableView.reloadData()
        updateNoDataLabelVisibility()
    }
    
    @IBAction func showRepairsOrders() {
        print("Filtering Repair Orders")
            filteredOrders = order_Detail.filter { $0.SaleType == "Fixes" } // Filter for repairs
            print("Filtered Orders Count for Repairs: \(filteredOrders.count)")
            TableView.reloadData()
            updateNoDataLabelVisibility()
    }
    
    func calculateSalesAmounts() {
        let today = Date()
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let todayString = dateFormatter.string(from: today)
        
        var totalSales: Double = 0.0
        var todaySales: Double = 0.0
        
        for order in order_Detail {
            if let amount = Double(order.amount) {
                totalSales += amount
                let orderDateString = dateFormatter.string(from: order.DateOfOrder)
                if orderDateString == todayString {
                    todaySales += amount
                }
            }
        }
        
        totalSalesAmount.text = String(format: "\(currency)%.2f", totalSales)
        todaySalesAmount.text = String(format: "\(currency)%.2f", todaySales)
    }
    func updateNoDataLabelVisibility() {
            Nodatalbl.isHidden = !filteredOrders.isEmpty
        }
    
    @IBAction func ViewAllSalesbutton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewSalesViewController") as! ViewSalesViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func CurrenctButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    @IBAction func settingsbtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func ShowSalesMen(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension OverviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "overviewCell", for: indexPath) as! OverviewTableViewCell
        
        let OrderData = filteredOrders[indexPath.row]
        cell.productNameLbl?.text = "Item: \(OrderData.product)"
        cell.salesTypeLabel?.text = OrderData.SaleType
        cell.saleMenNameLabel?.text = "SaleMan Name: \(OrderData.userName)"
        cell.amountOFProductLabel?.text = "\(currency) \(OrderData.amount)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        cell.dateLbl.text = dateFormatter.string(from: OrderData.DateOfOrder)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
