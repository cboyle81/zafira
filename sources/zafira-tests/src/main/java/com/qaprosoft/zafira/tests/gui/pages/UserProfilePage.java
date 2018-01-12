package com.qaprosoft.zafira.tests.gui.pages;

import com.qaprosoft.zafira.tests.exceptions.NoColorSchemaIsChosenException;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class UserProfilePage extends BasePage
{

	@FindBy(xpath = "//button[ancestor::form[@name='access_token_form'] and @type='submit']")
	private WebElement generateTokenButton;

	@FindBy(xpath = "//button[ancestor::form[@name='access_token_form'] and @type='button']")
	private WebElement copyTokenButton;

	@FindBy(xpath = "//input[@name='accessToken']")
	private WebElement tokenInput;

	@FindBy(xpath = "//div[contains(@class, 'ajs-success')]")
	private WebElement copyActionAlert;

	@FindBy(xpath="//body[contains(@class, 'zaf-light')]")
	private WebElement lightZafiraSchemaStyle;

	@FindBy(xpath="//body[contains(@class, 'zaf-dark')]")
	private WebElement darkZafiraSchemaStyle;

	@FindBy(xpath="//md-radio-button[@value=32]")
	private WebElement lightZafiraSchemaRadioButton;

	@FindBy(xpath="//md-radio-button[@value=22]")
	private WebElement darkZafiraSchemaRadioButton;

	@FindBy(xpath="//md-radio-button[@value=32 and contains(@class, 'md-checked')]")
	private WebElement lightZafiraSchemaRadioButtonChecked;

	@FindBy(xpath="//md-radio-button[@value=22 and contains(@class, 'md-checked')]")
	private WebElement darkZafiraSchemaRadioButtonChecked;

	public enum ColorSchema {LIGHT, DARK};

	public UserProfilePage(WebDriver driver)
	{
		super(driver, "/users/profile");
	}


	public ColorSchema checkCurrentColorSchemeByRadioButton(){
		this.waitUntilPageIsLoaded(4);
		if(lightZafiraSchemaRadioButtonChecked != null){
			return ColorSchema.LIGHT;
		}
		else if (darkZafiraSchemaRadioButtonChecked != null){
			return ColorSchema.DARK;
		}
		else {
			throw new NoColorSchemaIsChosenException("No radioButton corresponding to the schema choice was found");
		}
	}

	public void pickDarkSchemaRadioButton(){
		darkZafiraSchemaRadioButton.click();
	}

	public void pickLightSchemaRadioButton(){
		lightZafiraSchemaRadioButton.click();
	}

	public boolean darkSchemaStyleIsDisplayed(){
		return darkZafiraSchemaStyle != null;
	}

	public boolean lightSchemaStyleIsDisplayed(){
		return lightZafiraSchemaStyle != null;
	}

	public void generateToken()
	{
		this.waitUntilElementIsPresent(generateTokenButton, 3);
		generateTokenButton.click();
		this.waitUntilElementIsPresent(copyTokenButton, 1);
	}

	public boolean copyToken()
	{
		new WebDriverWait(driver, 5).until(ExpectedConditions
				.visibilityOfElementLocated(By.xpath("//header/div[contains(@class, 'profile-img')]")));
		generateTokenButton.click();
		new WebDriverWait(driver, 1).until(ExpectedConditions.visibilityOfElementLocated(
				By.xpath("//button[ancestor::form[@name='access_token_form'] and @type='button']")));
		copyTokenButton.click();
		return copyActionAlert != null;
	}

	public WebElement getTokenInput()
	{
		return tokenInput;
	}

	public WebElement getGenerateTokenButton() {
		return generateTokenButton;
	}

	public WebElement getCopyTokenButton() {
		return copyTokenButton;
	}

	public WebElement getCopyActionAlert() {
		return copyActionAlert;
	}

	public WebElement getLightZafiraSchemaStyle() {
		return lightZafiraSchemaStyle;
	}

	public WebElement getDarkZafiraSchemaStyle() {
		return darkZafiraSchemaStyle;
	}

	public WebElement getLightZafiraSchemaRadioButton() {
		return lightZafiraSchemaRadioButton;
	}

	public WebElement getDarkZafiraSchemaRadioButton() {
		return darkZafiraSchemaRadioButton;
	}

	public WebElement getLightZafiraSchemaRadioButtonChecked() {
		return lightZafiraSchemaRadioButtonChecked;
	}

	public WebElement getDarkZafiraSchemaRadioButtonChecked() {
		return darkZafiraSchemaRadioButtonChecked;
	}
}
