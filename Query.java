package project;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;
/**
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPasswordField;
import javax.swing.JTextField;
*/

public class Query {
	
	String jdbcUrl = "jdbc:postgresql://localhost:63333/eric4289";
	
	Connection conn;

	public Connection getDBConnection() throws SQLException{ 

		if(conn == null) {
			Scanner scanner = new Scanner(System.in);
			System.out.println("Enter Username: ");
			String username = scanner.nextLine();
			
			System.out.println("Enter Password: ");
			String password = scanner.nextLine();
			
			conn = DriverManager.getConnection(jdbcUrl, username, password);
		}
		conn.setAutoCommit(true);
		return conn;
	}

	public static void main(String[] args) throws Exception{ 
		Query q = new Query();
		Scanner scanner = new Scanner(System.in);
		System.out.println("What query will you run? Query 1 or Query 2? Enter here:");
		int response = scanner.nextInt();
		
		if(response == 1) {
			Scanner email_finder = new Scanner(System.in);
			System.out.println("What's the email: ");
			String email = email_finder.nextLine();
			q.Q1(email);
		}
		
		else if(response == 2) {
			q.Q2();
		}
		
		else {
			System.out.println("Try again.");
		}
	}
	
	/**
	 * Queries
	 *
	 * @throws SQLException
	 */
	public void Q1(String email)
					throws SQLException {

		getDBConnection();

		String product_pur =
				"SELECT pro.name " +
				"FROM purchase pur JOIN product pro ON pro.name = pur.name " +
				"WHERE email = ?";

		try(PreparedStatement q1Statement =
				conn.prepareStatement(product_pur);){

			q1Statement.setString(1, email);

			ResultSet rs  = q1Statement.executeQuery();
			
			while(rs.next()){
		         String name  = rs.getString("name");
		         
		         System.out.println(name);
			}

		} catch(SQLException e) {
			e.printStackTrace(); 
		} 
	}
	
	public void Q2()
			throws SQLException {

		getDBConnection();

		String top_5 =
				"SELECT *\r\n"
						+ "FROM (\r\n"
						+ "     SELECT *, row_number() OVER (PARTITION BY email ORDER BY avg_rate DESC) AS top_picks\r\n"
						+ "     FROM (\r\n"
						+ "          SELECT email, product.ASIN, avg_rate\r\n"
						+ "          FROM product, purchase\r\n"
						+ "          EXCEPT\r\n"
						+ "\r\n"
						+ "          SELECT email, ASIN, avg_rate\r\n"
						+ "          FROM purchase NATURAL JOIN product\r\n"
						+ "              ) AS a_query\r\n"
						+ "         ) AS b_query\r\n"
						+ "WHERE top_picks <= 5";

		try(PreparedStatement q2Statement =
				conn.prepareStatement(top_5);){

			ResultSet rs  = q2Statement.executeQuery();
	
			while(rs.next()){
				String email  = rs.getString("email");
				String ASIN  = rs.getString("ASIN");
				String avg_rate  = rs.getString("avg_rate");
         
				System.out.println(email + " " + ASIN + " " + avg_rate);
			}

		} catch(SQLException e) {
			e.printStackTrace(); 
		} 
	}
}